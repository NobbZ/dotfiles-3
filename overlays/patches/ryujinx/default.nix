{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  dotnetCorePackages,
  libX11,
  libgdiplus,
  ffmpeg,
  SDL2_mixer,
  openal,
  libsoundio,
  sndio,
  pulseaudio,
  gtk3,
  gdk-pixbuf,
  wrapGAppsHook,
}:
buildDotnetModule rec {
  pname = "ryujinx";
  version = "unstable-2022-03-07";

  src = fetchFromGitHub {
    owner = "Ryujinx";
    repo = "Ryujinx";
    rev = "54bfaa125d9b6ae1be53ec431d40326fba51d0de";
    sha256 = "0p8wmnm8sjx7wqb5z62mp8c3cwrv241ji3fawj2qgqx3k9jlb31i";
  };

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  projectFile = "Ryujinx.sln";
  nugetDeps = ./deps.nix;

  dotnetFlags = ["/p:ExtraDefineConstants=DISABLE_UPDATER"];

  # TODO: Add the headless frontend. Currently errors on the following:
  # System.Exception: SDL2 initlaization failed with error "No available video device"
  executables = ["Ryujinx"];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
  ];

  runtimeDeps = [
    gtk3
    libX11
    libgdiplus
    ffmpeg
    SDL2_mixer
    openal
    libsoundio
    sndio
    pulseaudio
  ];

  patches = [
    ./log.patch
    # Without this, Ryujinx attempts to write logs to the nix store. This patch makes it write to "~/.config/Ryujinx/Logs" on Linux.
  ];

  preInstall = ''
    # TODO: fix this hack https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6

    makeWrapperArgs+=(
      --suffix LD_LIBRARY_PATH : "$out/lib/sndio-6"
    )

    for i in 16 32 48 64 96 128 256 512 1024; do
      install -D ${src}/Ryujinx/Ui/Resources/Logo_Ryujinx.png $out/share/icons/hicolor/''${i}x$i/apps/ryujinx.png
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Ryujinx";
      name = "ryujinx";
      exec = "Ryujinx";
      icon = "ryujinx";
      comment = meta.description;
      type = "Application";
      categories = "Game;";
    })
  ];

  meta = with lib; {
    description = "Experimental Nintendo Switch Emulator written in C#";
    homepage = "https://ryujinx.org/";
    license = licenses.mit;
    changelog = "https://github.com/Ryujinx/Ryujinx/wiki/Changelog";
    maintainers = [maintainers.ivar];
    platforms = ["x86_64-linux"];
    mainProgram = "Ryujinx";
  };
  passthru.updateScript = ./updater.sh;
}
