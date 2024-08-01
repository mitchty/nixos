{
  lib,
  pkgs,
  fetchFromGitHub,
  python3,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "ytdl-sub";
  version = "2024.07.26";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "jmbannon";
    repo = "ytdl-sub";
    rev = "refs/tags/${version}";
    hash = "sha256-f/9jW/zl/I2NGTBlN+jVk4Td5Gf2qyy/OSIza/EJrqA=";
  };

  # Add ffmpeg from nix to default path
  postPatch = ''
    substituteInPlace src/ytdl_sub/config/defaults.py \
        --replace 'DEFAULT_FFMPEG_PATH = "/usr/bin/ffmpeg' \
        'DEFAULT_FFMPEG_PATH = "${pkgs.ffmpeg}/bin/ffmpeg' \
        --replace 'DEFAULT_FFPROBE_PATH = "/usr/bin/ffprobe"' \
        'DEFAULT_FFPROBE_PATH = "${pkgs.ffmpeg}/bin/ffprobe"'
  '';

  propagatedBuildInputs = with python3.pkgs; [
    mediafile
    mergedeep
    pyyaml
    yt-dlp
    colorama
  ];

  buildInputs = [ pkgs.ffmpeg ];

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.pythonRelaxDepsHook
  ];

  pythonRelaxDeps = true;

  pythonImportsCheck = [ "ytdl_sub" ];

  checkInputs = with python3.pkgs; [
    pytestCheckHook
    pytest
  ];

  disabledTests = [
    "test_logger_always_outputs_to_debug_file"
    "test_logger_can_be_cleaned_during_execution"
    "test_no_config_works"
  ];
  # Skip tests that use the network
  pytestFlagsArray = [
    "--ignore=tests/e2e"
    "--ignore=tests/unit/prebuilt_presets/test_prebuilt_presets.py"
  ];

  meta = with lib; {
    mainProgram = "ytdl-sub";
    description = "Automate downloading and metadata generation with YoutubeDL";
    homepage = "https://github.com/jmbannon/ytdl-sub";
    license = licenses.gpl3Only;
  };

  latest = "curl --silent 'https://api.github.com/repos/jmbannon/${pname}/releases/latest' | jq -r '.tag_name'";
}
