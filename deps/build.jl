using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    ExecutableProduct(prefix, "ANTS", :ants),
    ExecutableProduct(prefix, "antsRegistration", :antsRegistration),
    ExecutableProduct(prefix, "antsMotionCorr", :antsMotionCorr)
]

# Download binaries from hosted location
bin_prefix = "https://github.com/ianshmean/bins/raw/master/3rdparty/ANTS"
v = "2.1.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64) => ("$bin_prefix/$v/ANTs-MacOS_Yosemite.tar.gz", "71816d7a650156d99bee804195a1460c44f879242cf30fcd8cfff2833b9520ca"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/$v/ANTs-Linux_Ubuntu14.04.tar.gz", "6cb1bed27f0ece01eb3a0b4009a1afe03802b3f9aee1c5cbbd83184994e9e1b5"),
    Windows(:x86_64) => ("$bin_prefix/$v/ANTs-Windows.tar.gz", "94aa1eaaf2a74e864b854f05f923153c032a876ead3cef65874e9723b2ffce32"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
