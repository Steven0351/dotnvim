{
  description = "Dev Shell for dotnvim";

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs.unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = inputs: {
    devShell =
      let
        mkDevShell = pkgs:
          pkgs.mkShell {
            buildInputs = with pkgs; [
              sumneko-lua-language-server
              rnix-lsp
            ];
          };
      in
      {
        "x86_64-darwin" = mkDevShell
          inputs.unstable.legacyPackages."x86_64-darwin";
        "aarch64-darwin" = mkDevShell
          inputs.unstable.legacyPackages."aarch64-darwin";
        "x86_64-linux" = mkDevShell
          inputs.nixos-pkgs.legacyPackages."x86_64-linux";
        "aarch64-linux" = mkDevShell
          inputs.nixos-pkgs.legacyPackages."aarch64-linux";
      };
  };
}
