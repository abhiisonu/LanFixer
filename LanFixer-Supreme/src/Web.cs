using System.Diagnostics;
using System.Net;
using System.Text;
using System.Text.Json;

namespace LanFixer;

public static class WebServer
{
    private static HttpListener? _listener;
    private static CancellationTokenSource? _cts;
    private static readonly List<int> _history = new();
    private static readonly object _histLock = new();
    public static int Port = 49888;
    public static bool Running => _listener is { IsListening: true };

    public static void Start(int port = 49888, bool openBrowser = true)
    {
        if (Running)
        {
            if (openBrowser) OpenBrowser($"http://127.0.0.1:{Port}/");
            return;
        }

        Port = port;
        _cts = new CancellationTokenSource();

        for (int retry = 0; retry < 5; retry++)
        {
            try
            {
                _listener = new HttpListener();
                _listener.Prefixes.Add($"http://127.0.0.1:{Port}/");
                _listener.Start();
                break;
            }
            catch
            {
                Port++;
                _listener = null;
            }
        }

        if (_listener == null || !_listener.IsListening)
        {
            Console.Error.WriteLine("[!] Could not bind local HTTP server.");
            return;
        }

        Task.Run(() => ListenLoop(_listener, _cts.Token));

        var url = $"http://127.0.0.1:{Port}/";
        Console.WriteLine($"\n  ============================================================================");
        Console.WriteLine($"    LANFIXER SUPREME MODERN INDUSTRIAL WEB DASHBOARD ACTIVE");
        Console.WriteLine($"    URL : {url}");
        Console.WriteLine($"  ============================================================================\n");

        if (openBrowser)
        {
            OpenBrowser(url);
        }
    }

    public static void Stop()
    {
        try
        {
            _cts?.Cancel();
            _listener?.Stop();
            _listener?.Close();
        }
        catch { }
    }

    private static void OpenBrowser(string url)
    {
        try
        {
            Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
        }
        catch { }
    }

    private static async Task ListenLoop(HttpListener listener, CancellationToken ct)
    {
        while (!ct.IsCancellationRequested && listener.IsListening)
        {
            try
            {
                var ctx = await listener.GetContextAsync();
                _ = Task.Run(() => HandleRequest(ctx), ct);
            }
            catch (HttpListenerException) { break; }
            catch (ObjectDisposedException) { break; }
            catch { }
        }
    }

    private static async Task HandleRequest(HttpListenerContext ctx)
    {
        var req = ctx.Request;
        var resp = ctx.Response;

        resp.Headers.Add("Access-Control-Allow-Origin", "*");
        resp.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        resp.Headers.Add("Access-Control-Allow-Headers", "Content-Type");

        if (req.HttpMethod == "OPTIONS")
        {
            resp.StatusCode = 204;
            resp.Close();
            return;
        }

        var path = req.Url?.AbsolutePath.ToLowerInvariant() ?? "/";

        try
        {
            if (path is "/" or "/index.html")
            {
                var html = WebUi.GetHtml();
                var buf = Encoding.UTF8.GetBytes(html);
                resp.ContentType = "text/html; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/status")
            {
                var s = Fmt.Parse(Ipc.AskSync("status", 1000));
                if (s == null)
                {
                    var l = Net.Primary();
                    var (st, _, ms) = await Net.Probe(l?.Ip, default);
                    int gwMs = -1;
                    if (!string.IsNullOrEmpty(l?.Gw))
                    {
                        gwMs = await Net.Rtt(l.Gw, 1000);
                    }
                    var dnsServers = (l != null ? Dns.Current(l.Id).ToList() : new List<string>());
                    if (dnsServers.Count == 0) dnsServers.AddRange(new[] { "1.1.1.1", "8.8.8.8" });
                    int netMs = -1;
                    foreach (var srv in dnsServers)
                    {
                        netMs = await Dns.Ms(srv, default);
                        if (netMs >= 0) break;
                    }

                    lock (_histLock)
                    {
                        _history.Add(ms >= 0 ? ms : (gwMs >= 0 ? gwMs : 0));
                        if (_history.Count > 50) _history.RemoveAt(0);
                    }

                    List<string> logs;
                    lock (Log.Ring) { logs = Log.Ring.TakeLast(25).ToList(); }

                    s = new Status
                    {
                        State = l == null ? "NoLink" : st.ToString(),
                        Ms = ms,
                        GwMs = gwMs,
                        NetMs = netMs,
                        Loss = (ms < 0 && gwMs >= 0) ? 50 : (ms < 0 ? 100 : 0),
                        Heals = 0,
                        Adapter = l?.Name ?? "None",
                        Ip = l?.Ip ?? "",
                        Gw = l?.Gw ?? "",
                        Vault = Vault.Exists,
                        Susp = File.Exists(P.Susp),
                        Hist = new List<int>(_history),
                        Events = logs
                    };
                }
                var json = JsonSerializer.Serialize(s, J.Default.Status);
                var buf = Encoding.UTF8.GetBytes(json);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/doctor")
            {
                var doc = Doctor.Run();
                var json = JsonSerializer.Serialize(doc, J.Default.DoctorReport);
                var buf = Encoding.UTF8.GetBytes(json);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/bench")
            {
                var primary = Net.Primary();
                var res = await Bench.RunAsync(primary?.Gw);
                var json = JsonSerializer.Serialize(res, J.Default.ListBenchTarget);
                var buf = Encoding.UTF8.GetBytes(json);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/bundle")
            {
                Engine.Init();
                var msg = await Engine.CreateBundleAsync();
                var lines = msg.Split('\n');
                var filePath = lines.Length > 1 ? lines[1].Trim().Split(' ')[0] : null;
                byte[] buf;
                if (filePath != null && File.Exists(filePath))
                {
                    buf = await File.ReadAllBytesAsync(filePath);
                }
                else
                {
                    buf = Encoding.UTF8.GetBytes("{\"error\": \"Could not generate bundle\"}");
                }
                resp.ContentType = "application/json; charset=utf-8";
                resp.Headers.Add("Content-Disposition", $"attachment; filename=\"LanFixer-Bundle-{DateTime.Now:yyyyMMdd-HHmmss}.json\"");
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/cred")
            {
                if (req.HttpMethod == "GET")
                {
                    var cred = Vault.Load();
                    var dto = new CredInfoDto
                    {
                        Exists = Vault.Exists,
                        User = cred?.U ?? "",
                        Host = cred?.H ?? "",
                        Port = cred?.Port ?? 8888
                    };
                    var json = JsonSerializer.Serialize(dto, J.Default.CredInfoDto);
                    var buf = Encoding.UTF8.GetBytes(json);
                    resp.ContentType = "application/json; charset=utf-8";
                    resp.ContentLength64 = buf.Length;
                    await resp.OutputStream.WriteAsync(buf);
                }
                else if (req.HttpMethod == "POST")
                {
                    using var reader = new StreamReader(req.InputStream, req.ContentEncoding);
                    var body = await reader.ReadToEndAsync();
                    string u = "", p = "", h = "";
                    int port = 8888;
                    try
                    {
                        using var doc = JsonDocument.Parse(body);
                        if (doc.RootElement.TryGetProperty("u", out var up)) u = up.GetString() ?? "";
                        if (doc.RootElement.TryGetProperty("p", out var pp)) p = pp.GetString() ?? "";
                        if (doc.RootElement.TryGetProperty("h", out var hp)) h = hp.GetString() ?? "";
                        if (doc.RootElement.TryGetProperty("port", out var ptp)) port = ptp.GetInt32();
                    }
                    catch { }

                    bool ok = false;
                    string msg = "";
                    if (string.IsNullOrWhiteSpace(u) || string.IsNullOrWhiteSpace(p))
                    {
                        msg = "Username and password cannot be empty.";
                    }
                    else
                    {
                        var cred = new Cred { U = u, P = p, H = h, Port = port > 0 ? port : 8888 };
                        ok = Vault.Save(cred);
                        msg = ok ? $"Credentials successfully encrypted & stored in machine DPAPI vault (Target: {h}:{port})." : "Failed to encrypt credentials with DPAPI.";
                    }
                    var dto = new ActionResultDto { Ok = ok, Result = msg };
                    var json = JsonSerializer.Serialize(dto, J.Default.ActionResultDto);
                    var buf = Encoding.UTF8.GetBytes(json);
                    resp.ContentType = "application/json; charset=utf-8";
                    resp.ContentLength64 = buf.Length;
                    await resp.OutputStream.WriteAsync(buf);
                }
            }
            else if (path == "/api/logs")
            {
                List<string> logs;
                lock (Log.Ring) { logs = Log.Ring.TakeLast(50).ToList(); }
                var json = JsonSerializer.Serialize(logs, J.Default.ListString);
                var buf = Encoding.UTF8.GetBytes(json);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else if (path == "/api/action" && req.HttpMethod == "POST")
            {
                using var reader = new StreamReader(req.InputStream, req.ContentEncoding);
                var body = await reader.ReadToEndAsync();
                string cmd = "repair";
                try
                {
                    using var doc = JsonDocument.Parse(body);
                    if (doc.RootElement.TryGetProperty("cmd", out var cp)) cmd = cp.GetString() ?? "repair";
                }
                catch { }

                string? result = Ipc.AskSync(cmd);
                if (result == null)
                {
                    bool reqAdmin = cmd switch
                    {
                        "bench" or "bundle" or "audit" or "keepalive" or "doctor" => false,
                        _ => true
                    };
                    if (reqAdmin && !P.Admin())
                    {
                        result = "Elevated administrator privileges or background service required for this operation.";
                    }
                    else
                    {
                        Engine.Init();
                        result = await Engine.Do(cmd);
                    }
                }
                var dto = new ActionResultDto
                {
                    Ok = !result.StartsWith("Error") && !result.StartsWith("Refused") && !result.StartsWith("Aborted"),
                    Result = result
                };
                var json = JsonSerializer.Serialize(dto, J.Default.ActionResultDto);
                var buf = Encoding.UTF8.GetBytes(json);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buf.Length;
                await resp.OutputStream.WriteAsync(buf);
            }
            else
            {
                resp.StatusCode = 404;
                var buf = Encoding.UTF8.GetBytes("Not Found");
                await resp.OutputStream.WriteAsync(buf);
            }
        }
        catch (Exception ex)
        {
            try
            {
                resp.StatusCode = 500;
                var buf = Encoding.UTF8.GetBytes("Error: " + ex.Message);
                await resp.OutputStream.WriteAsync(buf);
            }
            catch { }
        }
        finally
        {
            try { resp.Close(); } catch { }
        }
    }
}

public static class WebUi
{
    public static string GetHtml() =>
"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LanFixer Supreme — Modern Autonomous Network Guardian</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #06080F;
      --card-bg: rgba(14, 20, 36, 0.75);
      --card-border: rgba(255, 255, 255, 0.08);
      --card-hover: rgba(22, 32, 56, 0.9);
      --cyan: #00F2FE;
      --cyan-dim: #0EA5E9;
      --cyan-glow: rgba(0, 242, 254, 0.35);
      --emerald: #10B981;
      --emerald-glow: rgba(16, 185, 129, 0.35);
      --amber: #F59E0B;
      --amber-glow: rgba(245, 158, 11, 0.35);
      --rose: #F43F5E;
      --rose-glow: rgba(244, 63, 94, 0.35);
      --purple: #8B5CF6;
      --text-1: #F8FAFC;
      --text-2: #94A3B8;
      --text-3: #64748B;
      --surface-1: #0B1120;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    ::-webkit-scrollbar { width: 8px; height: 8px; }
    ::-webkit-scrollbar-track { background: var(--bg); }
    ::-webkit-scrollbar-thumb { background: #1E293B; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #334155; }

    body {
      background: var(--bg);
      color: var(--text-1);
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
      background-image: 
        radial-gradient(ellipse 70% 50% at 15% -10%, rgba(14, 165, 233, 0.15), transparent 70%),
        radial-gradient(ellipse 60% 45% at 85% 110%, rgba(16, 185, 129, 0.12), transparent 70%),
        radial-gradient(ellipse 50% 40% at 50% 50%, rgba(139, 92, 246, 0.05), transparent 70%);
      background-attachment: fixed;
    }
    .container { max-width: 1360px; margin: 0 auto; width: 100%; padding: 24px 28px; display: flex; flex-direction: column; gap: 24px; }

    /* Top Navigation / Hero Bar */
    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px 24px;
      background: var(--card-bg);
      backdrop-filter: blur(24px) saturate(180%);
      border: 1px solid var(--card-border);
      border-radius: 20px;
      box-shadow: 0 16px 40px rgba(0,0,0,0.6);
      position: relative;
      overflow: hidden;
    }
    header::after {
      content: '';
      position: absolute;
      top: 0; left: 0; right: 0; height: 2px;
      background: linear-gradient(90deg, transparent, var(--cyan), var(--emerald), transparent);
    }
    .logo-area { display: flex; align-items: center; gap: 16px; }
    .logo-icon {
      width: 46px; height: 46px; border-radius: 14px;
      background: linear-gradient(135deg, #00F2FE, #2563EB);
      display: flex; align-items: center; justify-content: center;
      font-size: 24px; color: white;
      box-shadow: 0 0 24px var(--cyan-glow);
    }
    .logo-text h1 {
      font-size: 20px; font-weight: 800; letter-spacing: -0.03em;
      background: linear-gradient(to right, #FFFFFF, #93C5FD);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
      display: flex; align-items: center; gap: 8px;
    }
    .ver-badge {
      font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 6px;
      background: rgba(0, 242, 254, 0.15); color: var(--cyan); border: 1px solid rgba(0, 242, 254, 0.3);
      font-family: 'JetBrains Mono', monospace; vertical-align: middle;
    }
    .logo-text p { font-size: 12px; color: var(--text-2); font-weight: 500; margin-top: 2px; }

    .header-actions { display: flex; align-items: center; gap: 12px; }
    .btn-pill {
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid var(--card-border);
      color: var(--text-1);
      padding: 8px 14px;
      border-radius: 10px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      display: flex; align-items: center; gap: 6px;
      transition: all 0.2s ease;
    }
    .btn-pill:hover {
      background: rgba(255, 255, 255, 0.1);
      border-color: var(--cyan);
      box-shadow: 0 0 16px var(--cyan-glow);
    }
    .status-badge {
      display: flex; align-items: center; gap: 10px;
      padding: 8px 18px; border-radius: 9999px; font-size: 13px; font-weight: 800;
      letter-spacing: 0.03em; transition: all 0.3s ease; text-transform: uppercase;
      font-family: 'JetBrains Mono', monospace;
    }
    .status-online { background: rgba(16, 185, 129, 0.15); color: #34D399; border: 1px solid rgba(16, 185, 129, 0.35); box-shadow: 0 0 20px var(--emerald-glow); }
    .status-captive { background: rgba(245, 158, 11, 0.18); color: #FBBF24; border: 1px solid rgba(245, 158, 11, 0.4); box-shadow: 0 0 20px var(--amber-glow); }
    .status-offline { background: rgba(244, 63, 94, 0.18); color: #FB7185; border: 1px solid rgba(244, 63, 94, 0.4); box-shadow: 0 0 20px var(--rose-glow); }
    .pulse-dot { width: 10px; height: 10px; border-radius: 50%; background: currentColor; animation: pulse 1.8s infinite; }
    @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.8); } }

    /* Key Telemetry Grid */
    .grid-5 { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 16px; }
    .card {
      background: var(--card-bg);
      backdrop-filter: blur(24px);
      border: 1px solid var(--card-border);
      border-radius: 18px;
      padding: 20px;
      display: flex; flex-direction: column; gap: 10px;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      position: relative;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,0.4);
    }
    .card:hover { transform: translateY(-3px); border-color: rgba(0, 242, 254, 0.35); box-shadow: 0 16px 40px rgba(0,0,0,0.6); }
    .card-label {
      font-size: 11px; font-weight: 700; color: var(--text-2);
      letter-spacing: 0.05em; text-transform: uppercase;
      display: flex; align-items: center; justify-content: space-between;
    }
    .card-val {
      font-size: 32px; font-weight: 800; font-family: 'JetBrains Mono', monospace;
      color: var(--text-1); letter-spacing: -0.03em; display: flex; align-items: baseline; gap: 4px;
    }
    .card-val .unit { font-size: 14px; font-weight: 600; color: var(--text-2); }
    .card-sub { font-size: 12px; color: var(--text-3); font-weight: 500; display: flex; align-items: center; gap: 6px; }
    .tag-pill {
      font-size: 10px; font-weight: 800; padding: 2px 7px; border-radius: 4px;
      background: rgba(255,255,255,0.08); color: var(--text-2); font-family: 'JetBrains Mono', monospace;
    }
    .tag-emerald { background: rgba(16, 185, 129, 0.2); color: #34D399; }
    .tag-amber { background: rgba(245, 158, 11, 0.2); color: #FBBF24; }
    .tag-rose { background: rgba(244, 63, 94, 0.2); color: #FB7185; }

    /* Telemetry Waveform Card */
    .chart-card {
      background: var(--card-bg);
      backdrop-filter: blur(24px);
      border: 1px solid var(--card-border);
      border-radius: 20px;
      padding: 24px;
      display: flex; flex-direction: column; gap: 16px;
      box-shadow: 0 12px 36px rgba(0,0,0,0.5);
    }
    .chart-header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
    .chart-title { font-size: 15px; font-weight: 700; color: var(--text-1); display: flex; align-items: center; gap: 10px; }
    .chart-stats {
      display: flex; gap: 18px; font-size: 12px; font-family: 'JetBrains Mono', monospace;
      background: rgba(0,0,0,0.3); padding: 6px 14px; border-radius: 8px; border: 1px solid var(--card-border);
    }
    .chart-stats span { color: var(--text-3); }
    .chart-stats span b { color: var(--cyan); font-weight: 700; }
    .canvas-box { position: relative; width: 100%; height: 180px; }
    canvas { width: 100%; height: 100%; border-radius: 12px; display: block; }
    .chart-tooltip {
      position: absolute; display: none; background: #0E172A; border: 1px solid var(--cyan);
      padding: 6px 12px; border-radius: 6px; font-size: 11px; font-family: 'JetBrains Mono', monospace;
      pointer-events: none; box-shadow: 0 8px 24px rgba(0,0,0,0.8); z-index: 10;
    }

    /* Action Command Center */
    .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2px; }
    .section-title { font-size: 17px; font-weight: 700; display: flex; align-items: center; gap: 10px; letter-spacing: -0.01em; }
    .grid-actions { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; }
    .action-btn {
      background: rgba(14, 20, 36, 0.8);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 18px;
      display: flex; flex-direction: column; gap: 8px;
      cursor: pointer;
      text-align: left;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      color: var(--text-1);
      position: relative;
      overflow: hidden;
    }
    .action-btn::before {
      content: ''; position: absolute; inset: 0;
      background: radial-gradient(circle at top right, rgba(0, 242, 254, 0.12), transparent 70%);
      opacity: 0; transition: opacity 0.25s ease;
    }
    .action-btn:hover {
      background: var(--card-hover);
      transform: translateY(-3px);
      border-color: var(--cyan);
      box-shadow: 0 10px 30px var(--cyan-glow);
    }
    .action-btn:hover::before { opacity: 1; }
    .action-btn:active { transform: scale(0.98); }
    .action-top { display: flex; align-items: center; justify-content: space-between; }
    .action-icon { font-size: 26px; }
    .action-badge {
      font-size: 9px; font-weight: 800; padding: 2px 6px; border-radius: 4px;
      background: rgba(255, 255, 255, 0.08); color: var(--text-2); font-family: 'JetBrains Mono', monospace;
    }
    .action-name { font-size: 14px; font-weight: 700; letter-spacing: -0.01em; }
    .action-desc { font-size: 12px; color: var(--text-2); line-height: 1.4; }

    /* Split Section: 7-Layer OSI & Live Activity Stream */
    .split-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    @media (max-width: 1024px) { .split-2 { grid-template-columns: 1fr; } }

    /* OSI Diagnostic Matrix */
    .osi-card {
      background: var(--card-bg);
      backdrop-filter: blur(24px);
      border: 1px solid var(--card-border);
      border-radius: 20px;
      padding: 22px;
      display: flex; flex-direction: column; gap: 14px;
      box-shadow: 0 12px 36px rgba(0,0,0,0.5);
    }
    .osi-grid { display: flex; flex-direction: column; gap: 10px; max-height: 420px; overflow-y: auto; padding-right: 4px; }
    .osi-item {
      background: rgba(11, 17, 32, 0.7);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 12px 16px;
      display: flex; flex-direction: column; gap: 6px;
      transition: all 0.2s ease;
    }
    .osi-item:hover { border-color: rgba(0, 242, 254, 0.3); background: rgba(16, 24, 46, 0.85); }
    .osi-top { display: flex; align-items: center; justify-content: space-between; }
    .osi-layer { font-size: 11px; font-weight: 800; color: var(--cyan); font-family: 'JetBrains Mono', monospace; text-transform: uppercase; }
    .osi-pill { font-size: 10px; font-weight: 800; padding: 2px 8px; border-radius: 9999px; font-family: 'JetBrains Mono', monospace; }
    .osi-pill.ok { background: rgba(16, 185, 129, 0.2); color: #34D399; }
    .osi-pill.err { background: rgba(244, 63, 94, 0.2); color: #FB7185; }
    .osi-title { font-size: 13px; font-weight: 700; }
    .osi-evidence { font-size: 11px; color: var(--text-2); font-family: 'JetBrains Mono', monospace; word-break: break-all; }

    /* Live Activity Stream Terminal */
    .terminal-card {
      background: var(--card-bg);
      backdrop-filter: blur(24px);
      border: 1px solid var(--card-border);
      border-radius: 20px;
      padding: 22px;
      display: flex; flex-direction: column; gap: 14px;
      box-shadow: 0 12px 36px rgba(0,0,0,0.5);
    }
    .terminal-body {
      background: #060911;
      border: 1px solid rgba(255,255,255,0.06);
      border-radius: 12px;
      padding: 14px 16px;
      height: 420px;
      overflow-y: auto;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      display: flex; flex-direction: column; gap: 6px;
    }
    .log-line { display: flex; gap: 10px; line-height: 1.5; color: var(--text-2); }
    .log-ts { color: var(--text-3); }
    .log-msg { color: var(--text-1); }
    .log-tag { font-weight: 700; padding: 0 4px; border-radius: 3px; font-size: 10px; }
    .tag-info { background: rgba(14, 165, 233, 0.2); color: #38BDF8; }
    .tag-heal { background: rgba(16, 185, 129, 0.2); color: #34D399; }
    .tag-warn { background: rgba(245, 158, 11, 0.2); color: #FBBF24; }
    .tag-err { background: rgba(244, 63, 94, 0.2); color: #FB7185; }

    /* Modals */
    .modal-overlay {
      position: fixed; inset: 0; background: rgba(2, 6, 15, 0.85); backdrop-filter: blur(12px);
      display: flex; align-items: center; justify-content: center; z-index: 200;
      opacity: 0; pointer-events: none; transition: all 0.25s ease;
    }
    .modal-overlay.active { opacity: 1; pointer-events: auto; }
    .modal-box {
      background: #0B1120; border: 1px solid rgba(255, 255, 255, 0.12); border-radius: 24px;
      max-width: 760px; width: 92%; padding: 30px; display: flex; flex-direction: column; gap: 22px;
      box-shadow: 0 24px 70px rgba(0,0,0,0.9); transform: scale(0.94); transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .modal-overlay.active .modal-box { transform: scale(1); }
    .modal-header { display: flex; justify-content: space-between; align-items: center; }
    .modal-header h2 { font-size: 19px; font-weight: 800; display: flex; align-items: center; gap: 10px; }
    .modal-close {
      background: rgba(255,255,255,0.06); border: none; color: var(--text-2); width: 32px; height: 32px;
      border-radius: 8px; font-size: 16px; cursor: pointer; display: flex; align-items: center; justify-content: center;
      transition: background 0.2s;
    }
    .modal-close:hover { background: rgba(255,255,255,0.15); color: white; }

    .bench-table { width: 100%; border-collapse: collapse; font-family: 'JetBrains Mono', monospace; font-size: 12px; }
    .bench-table th { text-align: left; padding: 10px 12px; color: var(--text-3); border-bottom: 1px solid var(--card-border); font-size: 11px; text-transform: uppercase; }
    .bench-table td { padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.04); }

    /* Vault Form */
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-label { font-size: 12px; font-weight: 700; color: var(--text-2); }
    .form-input {
      background: #060911; border: 1px solid var(--card-border); border-radius: 10px;
      padding: 12px 14px; color: white; font-family: 'JetBrains Mono', monospace; font-size: 13px;
      outline: none; transition: border-color 0.2s;
    }
    .form-input:focus { border-color: var(--cyan); box-shadow: 0 0 12px var(--cyan-glow); }
    .btn-submit {
      background: linear-gradient(135deg, #00F2FE, #2563EB); border: none; border-radius: 12px;
      padding: 14px 20px; font-size: 14px; font-weight: 700; color: white; cursor: pointer;
      display: flex; align-items: center; justify-content: center; gap: 8px; transition: all 0.2s;
      box-shadow: 0 4px 20px var(--cyan-glow);
    }
    .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 30px var(--cyan-glow); }

    /* Toast */
    #toast {
      position: fixed; bottom: 28px; right: 28px;
      background: #0F172A; border: 1px solid rgba(0, 242, 254, 0.4); border-radius: 14px;
      padding: 14px 22px; font-size: 13px; font-weight: 600; color: white;
      box-shadow: 0 16px 40px rgba(0,0,0,0.8); transform: translateY(120px); opacity: 0;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1); z-index: 300; display: flex; align-items: center; gap: 12px;
    }
    #toast.show { transform: translateY(0); opacity: 1; }

    /* Keyboard shortcuts helper bar */
    .footer-bar {
      margin-top: 10px; display: flex; align-items: center; justify-content: space-between;
      font-size: 11px; color: var(--text-3); font-family: 'JetBrains Mono', monospace; padding: 0 4px;
    }
    .shortcuts { display: flex; gap: 14px; }
    kbd {
      background: rgba(255,255,255,0.08); padding: 2px 6px; border-radius: 4px; border: 1px solid var(--card-border);
      color: var(--text-2); font-weight: 700;
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Header -->
    <header>
      <div class="logo-area">
        <div class="logo-icon">⚡</div>
        <div class="logo-text">
          <h1>LANFIXER SUPREME <span class="ver-badge">v8.5 INDUSTRIAL</span></h1>
          <p>Dual-Core Autonomous Windows Network Guardian & Captive Engine</p>
        </div>
      </div>
      <div class="header-actions">
        <button class="btn-pill" onclick="openVaultModal()">
          <span>🔑</span> Credential Vault
        </button>
        <button class="btn-pill" onclick="openBench()">
          <span>📊</span> Speed Benchmark
        </button>
        <button class="btn-pill" onclick="downloadBundle()">
          <span>📦</span> Export Diagnostics
        </button>
        <div id="statusBadge" class="status-badge status-online">
          <span class="pulse-dot"></span>
          <span id="statusText">ONLINE</span>
        </div>
      </div>
    </header>

    <!-- 5 Live Key Telemetry Cards -->
    <div class="grid-5">
      <div class="card">
        <div class="card-label"><span>Global Egress RTT</span> 🌐</div>
        <div class="card-val"><span id="valWeb">--</span> <span class="unit">ms</span></div>
        <div class="card-sub"><span id="badgeWeb" class="tag-pill tag-emerald">OPTIMAL</span> Cloudflare / Google Anycast</div>
      </div>
      <div class="card">
        <div class="card-label"><span>Gateway Reachability</span> 🚪</div>
        <div class="card-val"><span id="valGw">--</span> <span class="unit">ms</span></div>
        <div id="subGw" class="card-sub"><span class="tag-pill">L2/L3 HOP</span> Gateway: --</div>
      </div>
      <div class="card">
        <div class="card-label"><span>DNS Resolution Racer</span> ⚡</div>
        <div class="card-val"><span id="valDns">--</span> <span class="unit">ms</span></div>
        <div class="card-sub"><span class="tag-pill">UDP 53</span> Public Resolver Query</div>
      </div>
      <div class="card">
        <div class="card-label"><span>Packet Loss & Jitter</span> 🛡️</div>
        <div class="card-val"><span id="valLoss">0</span> <span class="unit">%</span></div>
        <div id="subLoss" class="card-sub"><span class="tag-pill">JITTER</span> <span id="valJit">0.0 ms</span> · MTU: 1500</div>
      </div>
      <div class="card">
        <div class="card-label"><span>Active Primary NDIS</span> 💻</div>
        <div id="valNic" class="card-val" style="font-size:20px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">Detecting...</div>
        <div id="subNic" class="card-sub"><span class="tag-pill tag-emerald">SHIELD ON</span> IP: --</div>
      </div>
    </div>

    <!-- Live Telemetry Graph Waveform -->
    <div class="chart-card">
      <div class="chart-header">
        <div class="chart-title">
          <span>📈 Real-Time Latency Waveform Telemetry (Rolling 50 Probes)</span>
        </div>
        <div class="chart-stats">
          <span>Min: <b id="statMin">--</b></span>
          <span>Avg: <b id="statAvg">--</b></span>
          <span>Max: <b id="statMax">--</b></span>
          <span>P95: <b id="statP95">--</b></span>
          <span>Jitter: <b id="statJit">--</b></span>
        </div>
      </div>
      <div class="canvas-box">
        <canvas id="chart"></canvas>
        <div id="chartTooltip" class="chart-tooltip"></div>
      </div>
    </div>

    <!-- Action Center -->
    <div>
      <div class="section-header">
        <h2 class="section-title">⚡ Autonomous Defense & Performance Operations</h2>
      </div>
      <div class="grid-actions">
        <button class="action-btn" onclick="runAction('repair')">
          <div class="action-top">
            <span class="action-icon">🩺</span>
            <span class="action-badge">TIER 1-3</span>
          </div>
          <span class="action-name">Escalating Repair</span>
          <span class="action-desc">DNS flush, ARP clear, route shield assertion, and socket revive.</span>
        </button>
        <button class="action-btn" onclick="runAction('login')">
          <div class="action-top">
            <span class="action-icon">🔑</span>
            <span class="action-badge">PORT 8888</span>
          </div>
          <span class="action-name">Portal Sign-In</span>
          <span class="action-desc">Instant campus portal auth preserving pfSense port 8888 safely.</span>
        </button>
        <button class="action-btn" onclick="runAction('mtu')">
          <div class="action-top">
            <span class="action-icon">📐</span>
            <span class="action-badge">PMTUD</span>
          </div>
          <span class="action-name">Path MTU Optimizer</span>
          <span class="action-desc">Probe black-hole MTU and clamp adapter to optimal 1492/1500.</span>
        </button>
        <button class="action-btn" onclick="runAction('pnp')">
          <div class="action-top">
            <span class="action-icon">🛡️</span>
            <span class="action-badge">NDIS POWER</span>
          </div>
          <span class="action-name">PnP Sleep Shield</span>
          <span class="action-desc">Enforce hardware power shield to eliminate adapter sleep drops.</span>
        </button>
        <button class="action-btn" onclick="runAction('tune1')">
          <div class="action-top">
            <span class="action-icon">🚀</span>
            <span class="action-badge">KERNEL TCP</span>
          </div>
          <span class="action-name">Precision Debloat</span>
          <span class="action-desc">Apply CTCP congestion control, ECN negotiation, and autotuning.</span>
        </button>
        <button class="action-btn" onclick="openBench()">
          <div class="action-top">
            <span class="action-icon">📊</span>
            <span class="action-badge">ANYCAST</span>
          </div>
          <span class="action-name">Anycast Benchmark</span>
          <span class="action-desc">Compare top 6 CDN resolvers and calculate exact network jitter.</span>
        </button>
        <button class="action-btn" onclick="runAction('keepalive')">
          <div class="action-top">
            <span class="action-icon">💓</span>
            <span class="action-badge">SESSION</span>
          </div>
          <span class="action-name">Keep-Alive Ping</span>
          <span class="action-desc">Transmit micro-probe to refresh captive portal idle session timeout.</span>
        </button>
        <button class="action-btn" onclick="downloadBundle()">
          <div class="action-top">
            <span class="action-icon">📦</span>
            <span class="action-badge">SANITY JSON</span>
          </div>
          <span class="action-name">Export Diagnostics</span>
          <span class="action-desc">Generate complete sanitized IT audit package for network teams.</span>
        </button>
        <button class="action-btn" onclick="runAction('rollback')">
          <div class="action-top">
            <span class="action-icon">🔄</span>
            <span class="action-badge">WRITE-AHEAD</span>
          </div>
          <span class="action-name">Undo Last Action</span>
          <span class="action-desc">Revert the most recent change with drift-protection verification.</span>
        </button>
      </div>
    </div>

    <!-- Split Section: 7-Layer OSI & Live Activity Stream -->
    <div class="split-2">
      <!-- 7-Layer OSI Matrix -->
      <div class="osi-card">
        <div class="section-header">
          <h2 class="section-title">🩺 7-Layer OSI Diagnostic Matrix</h2>
          <button class="btn-pill" onclick="pollDoctor()"><span>🔄</span> Re-Audit</button>
        </div>
        <div id="osiContainer" class="osi-grid">
          <div class="osi-item"><div class="osi-top"><span class="osi-layer">Auditing OSI Stack...</span></div></div>
        </div>
      </div>

      <!-- Live Event Stream -->
      <div class="terminal-card">
        <div class="section-header">
          <h2 class="section-title">📟 Live Engine & Telemetry Stream</h2>
          <div style="display:flex; gap:8px;">
            <button class="btn-pill" onclick="copyLogs()"><span>📋</span> Copy</button>
            <button class="btn-pill" onclick="clearLogs()"><span>🧹</span> Clear</button>
          </div>
        </div>
        <div id="terminalBody" class="terminal-body">
          <div class="log-line"><span class="log-ts">--:--:--</span><span class="log-msg">Connecting to LanFixer Supreme telemetry pipeline...</span></div>
        </div>
      </div>
    </div>

    <div class="footer-bar">
      <div class="shortcuts">
        <span>Shortcuts:</span>
        <span><kbd>R</kbd> Repair</span>
        <span><kbd>L</kbd> Login</span>
        <span><kbd>B</kbd> Benchmark</span>
        <span><kbd>D</kbd> OSI Doctor</span>
        <span><kbd>V</kbd> Vault</span>
      </div>
      <div>Zero External Dependencies · 100% Offline-First Native Windows Architecture</div>
    </div>
  </div>

  <!-- Bench Modal -->
  <div id="benchModal" class="modal-overlay" onclick="closeBench(event)">
    <div class="modal-box" onclick="event.stopPropagation()">
      <div class="modal-header">
        <h2>📊 Anycast Latency & Jitter Benchmark</h2>
        <button class="modal-close" onclick="closeBench()">✕</button>
      </div>
      <table class="bench-table">
        <thead>
          <tr>
            <th>Provider</th>
            <th>Target IP</th>
            <th>Min</th>
            <th>Avg</th>
            <th>Max</th>
            <th>Jitter</th>
            <th>DNS RTT</th>
          </tr>
        </thead>
        <tbody id="benchTbody">
          <tr><td colspan="7" style="text-align:center; padding:24px; color:var(--text-3);">Executing benchmark across 6 Anycast endpoints...</td></tr>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Credential Vault Modal -->
  <div id="vaultModal" class="modal-overlay" onclick="closeVaultModal(event)">
    <div class="modal-box" onclick="event.stopPropagation()" style="max-width:540px;">
      <div class="modal-header">
        <h2>🔑 Encrypted Portal Vault Manager</h2>
        <button class="modal-close" onclick="closeVaultModal()">✕</button>
      </div>
      <p style="font-size:12px; color:var(--text-2); line-height:1.5;">
        Credentials are encrypted directly with Windows Machine DPAPI (Data Protection API) and locked to Administrator/SYSTEM permissions.
      </p>
      <form onsubmit="saveCredentials(event)" style="display:flex; flex-direction:column; gap:14px;">
        <div class="form-group">
          <label class="form-label">Portal Username / Roll Number</label>
          <input id="credUser" type="text" class="form-input" placeholder="e.g. 2022UGCS001" required />
        </div>
        <div class="form-group">
          <label class="form-label">Portal Password</label>
          <input id="credPass" type="password" class="form-input" placeholder="••••••••••••" required />
        </div>
        <div style="display:grid; grid-template-columns: 2fr 1fr; gap:12px;">
          <div class="form-group">
            <label class="form-label">Portal Host / IP (Optional)</label>
            <input id="credHost" type="text" class="form-input" placeholder="e.g. 172.16.0.1" />
          </div>
          <div class="form-group">
            <label class="form-label">Port</label>
            <input id="credPort" type="number" class="form-input" value="8888" />
          </div>
        </div>
        <button type="submit" class="btn-submit" style="margin-top:8px;">
          <span>🔒</span> Save into DPAPI Machine Vault
        </button>
      </form>
    </div>
  </div>

  <!-- Toast -->
  <div id="toast"><span>⚡ Action dispatched successfully.</span></div>

  <script>
    let rawHistory = [];

    function toast(msg) {
      const t = document.getElementById('toast');
      t.innerHTML = `<span>${msg}</span>`;
      t.classList.add('show');
      setTimeout(() => t.classList.remove('show'), 3800);
    }

    async function pollStatus() {
      try {
        const res = await fetch('/api/status');
        const s = await res.json();

        // Status Badge
        const b = document.getElementById('statusBadge');
        const bt = document.getElementById('statusText');
        const st = s.State || 'Offline';
        b.className = 'status-badge ' + (st === 'Online' ? 'status-online' : (st === 'Captive' ? 'status-captive' : 'status-offline'));
        bt.textContent = st.toUpperCase();

        // 5 Metric Cards
        const webMs = s.Ms;
        const valWeb = document.getElementById('valWeb');
        const badgeWeb = document.getElementById('badgeWeb');
        if (webMs >= 0) {
          valWeb.textContent = webMs;
          if (webMs < 40) { badgeWeb.className = 'tag-pill tag-emerald'; badgeWeb.textContent = 'LIGHTNING'; }
          else if (webMs < 120) { badgeWeb.className = 'tag-pill tag-emerald'; badgeWeb.textContent = 'OPTIMAL'; }
          else { badgeWeb.className = 'tag-pill tag-amber'; badgeWeb.textContent = 'HIGH RTT'; }
        } else {
          valWeb.textContent = '--';
          badgeWeb.className = 'tag-pill tag-rose'; badgeWeb.textContent = 'EGRESS BLOCKED';
        }

        document.getElementById('valGw').textContent = (s.GwMs >= 0 ? s.GwMs : '--');
        document.getElementById('subGw').innerHTML = `<span class="tag-pill">GATEWAY</span> ${s.Gw || 'None'}`;

        document.getElementById('valDns').textContent = (s.NetMs >= 0 ? s.NetMs : '--');

        document.getElementById('valLoss').textContent = s.Loss;

        const nicElem = document.getElementById('valNic');
        nicElem.textContent = s.Adapter || 'None';
        document.getElementById('subNic').innerHTML = `<span class="tag-pill tag-emerald">ACTIVE</span> IP: ${s.Ip || 'None'}`;

        // Telemetry Chart
        if (s.Hist && s.Hist.length > 0) {
          rawHistory = s.Hist;
          drawChart(rawHistory);
        }

        // Live Log Stream
        const evts = s.Events || s.Evts;
        if (evts && evts.length > 0) {
          updateTerminal(evts);
        }
      } catch (e) {}
    }

    async function pollDoctor() {
      try {
        const res = await fetch('/api/doctor');
        const d = await res.json();
        const cont = document.getElementById('osiContainer');
        cont.innerHTML = '';

        d.Layers.forEach(l => {
          const ok = l.Status === 'OK';
          const item = document.createElement('div');
          item.className = 'osi-item';
          item.innerHTML = `
            <div class="osi-top">
              <span class="osi-layer">Layer ${l.Layer} · ${l.Name}</span>
              <span class="osi-pill ${ok ? 'ok' : 'err'}">${l.Status}</span>
            </div>
            <div class="osi-evidence">${l.Evidence}</div>
          `;
          cont.appendChild(item);
        });
      } catch (e) {}
    }

    function updateTerminal(events) {
      const term = document.getElementById('terminalBody');
      term.innerHTML = '';
      events.forEach(e => {
        const line = document.createElement('div');
        line.className = 'log-line';
        
        let tagHtml = '<span class="log-tag tag-info">INFO</span>';
        if (e.includes('repair') || e.includes('heal') || e.includes('Restored')) tagHtml = '<span class="log-tag tag-heal">HEAL</span>';
        else if (e.includes('Captive') || e.includes('Suspended')) tagHtml = '<span class="log-tag tag-warn">PORTAL</span>';
        else if (e.includes('fail') || e.includes('Error') || e.includes('Offline')) tagHtml = '<span class="log-tag tag-err">WARN</span>';

        const parts = e.split(' ');
        const ts = parts.length > 1 ? parts[1] : '';
        const msg = parts.slice(2).join(' ') || e;

        line.innerHTML = `<span class="log-ts">${ts}</span> ${tagHtml} <span class="log-msg">${msg}</span>`;
        term.appendChild(line);
      });
      term.scrollTop = term.scrollHeight;
    }

    function drawChart(data) {
      const cvs = document.getElementById('chart');
      const ctx = cvs.getContext('2d');
      const dpr = window.devicePixelRatio || 1;
      const rect = cvs.getBoundingClientRect();
      const w = cvs.width = rect.width * dpr;
      const h = cvs.height = rect.height * dpr;

      ctx.clearRect(0, 0, w, h);
      if (!data || data.length < 2) return;

      const valids = data.filter(v => v >= 0);
      if (valids.length === 0) return;

      const min = Math.min(...valids);
      const max = Math.max(...valids, 1);
      const avg = Math.round(valids.reduce((a, b) => a + b, 0) / valids.length);
      const sorted = [...valids].sort((a,b)=>a-b);
      const p95 = sorted[Math.floor(sorted.length * 0.95)] || max;
      const jit = (Math.sqrt(valids.reduce((a, v) => a + Math.pow(v - avg, 2), 0) / valids.length)).toFixed(1);

      document.getElementById('statMin').textContent = min + 'ms';
      document.getElementById('statAvg').textContent = avg + 'ms';
      document.getElementById('statMax').textContent = max + 'ms';
      document.getElementById('statP95').textContent = p95 + 'ms';
      document.getElementById('statJit').textContent = jit + 'ms';
      document.getElementById('valJit').textContent = jit + ' ms';

      const pad = 24 * dpr;
      const step = (w - pad * 2) / (data.length - 1);
      const range = Math.max(max - min, 20);

      // Horizontal Grid lines
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.05)';
      ctx.lineWidth = 1 * dpr;
      for (let g = 0; g < 4; g++) {
        const gy = pad + (g / 3) * (h - pad * 2);
        ctx.beginPath();
        ctx.moveTo(pad, gy);
        ctx.lineTo(w - pad, gy);
        ctx.stroke();
      }

      // Smooth Bezier Curve Path
      const points = data.map((v, i) => {
        const val = v >= 0 ? v : min;
        return {
          x: pad + i * step,
          y: h - pad - ((val - min) / range) * (h - pad * 2)
        };
      });

      // Gradient Fill
      const grad = ctx.createLinearGradient(0, 0, 0, h);
      grad.addColorStop(0, 'rgba(0, 242, 254, 0.35)');
      grad.addColorStop(0.5, 'rgba(0, 242, 254, 0.12)');
      grad.addColorStop(1, 'rgba(0, 242, 254, 0.0)');

      ctx.beginPath();
      ctx.moveTo(points[0].x, points[0].y);
      for (let i = 0; i < points.length - 1; i++) {
        const xc = (points[i].x + points[i + 1].x) / 2;
        const yc = (points[i].y + points[i + 1].y) / 2;
        ctx.quadraticCurveTo(points[i].x, points[i].y, xc, yc);
      }
      ctx.lineTo(points[points.length - 1].x, points[points.length - 1].y);

      // Stroke Line
      ctx.save();
      ctx.shadowColor = '#00F2FE';
      ctx.shadowBlur = 12 * dpr;
      ctx.strokeStyle = '#00F2FE';
      ctx.lineWidth = 3 * dpr;
      ctx.stroke();
      ctx.restore();

      // Complete path for gradient fill
      ctx.lineTo(points[points.length - 1].x, h);
      ctx.lineTo(points[0].x, h);
      ctx.closePath();
      ctx.fillStyle = grad;
      ctx.fill();

      // Latest point pulse
      const lastP = points[points.length - 1];
      ctx.beginPath();
      ctx.arc(lastP.x, lastP.y, 5 * dpr, 0, Math.PI * 2);
      ctx.fillStyle = '#00F2FE';
      ctx.fill();
    }

    async function runAction(cmd) {
      toast(`⚡ Executing operation: ${cmd}...`);
      try {
        const res = await fetch('/api/action', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ cmd })
        });
        const r = await res.json();
        toast(r.result);
        pollStatus();
        pollDoctor();
      } catch (e) {
        toast(`Error: ${e.message}`);
      }
    }

    async function openBench() {
      const modal = document.getElementById('benchModal');
      modal.classList.add('active');
      const tbody = document.getElementById('benchTbody');
      tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:24px; color:var(--text-3);">Executing benchmark across 6 Anycast endpoints...</td></tr>';
      
      try {
        const res = await fetch('/api/bench');
        const list = await res.json();
        tbody.innerHTML = '';
        list.forEach(r => {
          const tr = document.createElement('tr');
          tr.innerHTML = `
            <td style="font-weight:700; color:white;">${r.Name}</td>
            <td style="color:var(--cyan);">${r.Ip}</td>
            <td style="color:#34D399;">${r.PingMin >= 0 ? r.PingMin + 'ms' : '--'}</td>
            <td style="color:white; font-weight:700;">${r.PingAvg >= 0 ? r.PingAvg + 'ms' : '--'}</td>
            <td style="color:#FBBF24;">${r.PingMax >= 0 ? r.PingMax + 'ms' : '--'}</td>
            <td style="color:var(--cyan);">${r.JitterMs}ms</td>
            <td>${r.DnsMs >= 0 ? r.DnsMs + 'ms' : '--'}</td>
          `;
          tbody.appendChild(tr);
        });
      } catch (e) {
        tbody.innerHTML = `<tr><td colspan="7" style="color:var(--rose);">Error running benchmark: ${e.message}</td></tr>`;
      }
    }

    function closeBench(e) {
      document.getElementById('benchModal').classList.remove('active');
    }

    async function openVaultModal() {
      const modal = document.getElementById('vaultModal');
      modal.classList.add('active');
      try {
        const res = await fetch('/api/cred');
        const c = await res.json();
        if (c.Exists) {
          document.getElementById('credUser').value = c.User || '';
          document.getElementById('credHost').value = c.Host || '';
          document.getElementById('credPort').value = c.Port || 8888;
        }
      } catch (e) {}
    }

    function closeVaultModal(e) {
      document.getElementById('vaultModal').classList.remove('active');
    }

    async function saveCredentials(e) {
      e.preventDefault();
      const u = document.getElementById('credUser').value;
      const p = document.getElementById('credPass').value;
      const h = document.getElementById('credHost').value;
      const port = parseInt(document.getElementById('credPort').value) || 8888;

      try {
        const res = await fetch('/api/cred', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ u, p, h, port })
        });
        const r = await res.json();
        toast(r.result);
        closeVaultModal();
        pollStatus();
      } catch (e) {
        toast(`Error saving vault: ${e.message}`);
      }
    }

    function downloadBundle() {
      toast('📦 Packaging sanitized diagnostics bundle...');
      window.location.href = '/api/bundle';
    }

    function copyLogs() {
      const text = document.getElementById('terminalBody').innerText;
      navigator.clipboard.writeText(text);
      toast('📋 Logs copied to clipboard.');
    }

    function clearLogs() {
      document.getElementById('terminalBody').innerHTML = '<div class="log-line"><span class="log-ts">--:--:--</span><span class="log-msg">Log stream cleared.</span></div>';
      toast('🧹 Stream display cleared.');
    }

    // Global Keyboard Shortcuts
    window.addEventListener('keydown', (e) => {
      if (e.target.tagName === 'INPUT') return;
      const k = e.key.toUpperCase();
      if (k === 'R') runAction('repair');
      else if (k === 'L') runAction('login');
      else if (k === 'B') openBench();
      else if (k === 'D') pollDoctor();
      else if (k === 'V') openVaultModal();
      else if (k === 'ESCAPE') { closeBench(); closeVaultModal(); }
    });

    setInterval(pollStatus, 1500);
    pollStatus();
    pollDoctor();
  </script>
</body>
</html>
""";
}
