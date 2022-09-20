{ stdenv
, lib
, stable
}:
# Like minio...ish
# TODO: Get this building again on macos, some weird cgo things going on with go-ieproxy
# Leaving not working efforts inline for future me to know what doesn't work.
with stable; buildGo118Module rec {
  oname = "chrislusf";
  pname = "seaweedfs";
  version = "3.27";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = version;
    sha256 = "sha256-kvKUgw6A4UHOuDmKuOv+XS/0XiOf2ENWxl2WmJ4cVTE=";
  };

  vendorSha256 = "sha256-sgLHRDdi9gkcSzeBaDCxtbvWSzjTshb2WbmMyRepUKA=";

  subPackages = [ "weed" ];

  postInstall = ''
    install -dm755 $out/sbin
    ln -sf $out/bin/weed $out/sbin/mount.weed
  '';

  # Macos needs a few Core system libraries for c interop, mostly
  # CFNetwork for this new dep:
  # https://github.com/mattn/go-ieproxy/blob/master/ieproxy_darwin.go#L3-L8
  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.CFNetwork
  ];

  # Note have to do this impurely as we end up missing symbols due to cgo nonsense
  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-framework CoreServices -framework Foundation -framework CFNetwork";
  # CGO_ENABLED = lib.optional stdenv.isDarwin "1";

  # No worky...
  # preConfigure = lib.optionalString stdenv.isDarwin ''
  #   export NIX_LDFLAGS="-F${darwin.apple_sdk.frameworks.CFNetwork}/Library/Frameworks -framework CFNetwork -F${darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation -F${darwin.apple_sdk.frameworks.CoreServices}/Library/Frameworks -framework CoreServices $NIX_LDFLAGS"
  # '';

  meta.mainProgram = "weed";

  passthru.tests.version = testVersion { package = seaweedfs; command = "weed version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/chrislusf/seaweedfs/releases/latest' | jq -r '.tag_name'";
}
