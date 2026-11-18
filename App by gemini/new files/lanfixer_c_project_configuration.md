<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <RuntimeIdentifier>win-x64</RuntimeIdentifier>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>

    <!-- Single-File Self-Contained Bundle (Zero external .dll, .pdb, or .json files) -->
    <PublishSingleFile>true</PublishSingleFile>
    <SelfContained>true</SelfContained>
    <IncludeAllContentForSelfExtract>true</IncludeAllContentForSelfExtract>
    <IncludeNativeLibrariesForSelfExtract>true</IncludeNativeLibrariesForSelfExtract>
    <EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>
    <DebugType>none</DebugType>
    <DebugSymbols>false</DebugSymbols>
    <OptimizationPreference>Speed</OptimizationPreference>

    <AssemblyName>LanFixer</AssemblyName>
    <Version>7.0.2</Version>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="System.Security.Cryptography.ProtectedData" Version="8.0.0" />
    <PackageReference Include="System.ServiceProcess.ServiceController" Version="8.0.0" />
  </ItemGroup>

</Project>