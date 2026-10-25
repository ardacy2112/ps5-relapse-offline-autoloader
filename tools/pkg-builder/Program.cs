using LibProsperoPkg;

if (args.Length < 2)
{
    Console.WriteLine("usage: pkg-builder <source-folder> <output-folder>");
    return 1;
}

var result = ProsperoHomebrewPackager.Package(new ProsperoHomebrewPackageOptions
{
    HomebrewFolder = args[0],
    OutputFolder = args[1],
}, Console.WriteLine);

Console.WriteLine();
Console.WriteLine($"PKG: {result.OutputPath}");
Console.WriteLine($"Launch ready: {result.LaunchReadiness.IsLaunchReady}");
foreach (var w in result.Warnings)
    Console.WriteLine($"Warning: {w}");

return 0;
