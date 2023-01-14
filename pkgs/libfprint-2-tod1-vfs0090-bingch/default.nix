{ stdenv, lib, fetchFromGitLab, pkg-config, libfprint-tod, gusb, udev, nss, openssl, meson, pixman, ninja, glib, python3, python3Packages, python-validity, calib-data }:
stdenv.mkDerivation {
  pname = "libfprint-2-tod1-vfs0090";
  version = "0.8.5";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "bingch";
    repo = "libfprint-tod-vfs0090";
    rev = "3a5e27bc4e5dbbb42b953958796830e87b82d843";
    sha256 = "sha256-s6YPBeUYWBRUpVAsBvCKKTGQ8juMbPuJYWzXxKpcJkk=";
  };

  patches = [
    # TODO remove once https://gitlab.freedesktop.org/3v1n0/libfprint-tod-vfs0090/-/merge_requests/1 is merged
    ./0001-vfs0090-add-missing-explicit-dependencies-in-meson.b.patch
    # TODO remove once https://gitlab.freedesktop.org/3v1n0/libfprint-tod-vfs0090/-/merge_requests/2 is merged
    ./0002-vfs0090-add-missing-linux-limits.h-include.patch
    # TODO remove once libfprint-tod is upgraded to a more recent version
    ./0003-vfs0090-adapt-to-old-libfprint-fpi-ssm-api.patch
    ./0004-vfs0090-adapt-to-old-libfprint-api.patch

    ./0005-gen-scan-matrix-fail-without-calib-data.patch
  ];

  postPatch = ''
    substituteInPlace ./gen_scan_matrix.py \
      --replace "calib_data_path" "'${calib-data}/share/calib-data.bin'"

    # substituteInPlace ./gen_scan_matrix.py \
    #   --replace "#!/usr/bin/python" "#!/usr/bin/env python3"

    # substituteInPlace ./gen_scan_matrix.py \
    #   --replace "calib_data_path" "{calibDataPath}"

    # the python script must be executable, otherwise it wont be wrapped
    # chmod +x gen_scan_matrix.py
    # wrapPythonProgramsIn ./ "$out $pythonPath"
  '';

  nativeBuildInputs = [ pkg-config meson ninja python3 python3Packages.wrapPython python-validity ];
  buildInputs = [ libfprint-tod glib gusb udev nss openssl pixman ];

  installPhase = ''
    runHook preInstall

    install -D -t "$out/lib/libfprint-2/tod-1/" libfprint-tod-vfs009x.so
    install -D -t "$out/lib/udev/rules.d/" $src/60-libfprint-2-tod-vfs0090.rules

    runHook postInstall
  '';

  passthru.driverPath = "/lib/libfprint-2/tod-1";

  meta = with lib; {
    description = "A libfprint-2-tod Touch OEM Driver for 2016 ThinkPad's fingerprint readers";
    homepage = "https://gitlab.freedesktop.org/3v1n0/libfprint-tod-vfs0090";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ valodim ];
  };
}
