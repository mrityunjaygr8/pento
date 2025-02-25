{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [git] ++ lib.optionals pkgs.stdenv.isLinux [pkgs.inotify-tools];


  # https://devenv.sh/languages/
  languages.elixir.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  services.postgres = {
    listen_addresses = "127.0.0.1";
    initialScript = ''
      CREATE USER postgres WITH SUPERUSER PASSWORD 'dr0w.Ssap';
    '';
    enable = true;
    initialDatabases = [
      {
        name = "pento";
        user = "pento";
        pass = "pento";
      }
    ];
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/

  cachix.enable = if pkgs.stdenv.isDarwin then false else true;
}
