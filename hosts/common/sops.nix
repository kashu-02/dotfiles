_: {
  # Only encrypted files belong in the Nix store. Define sopsFile per secret
  # when adding the first secrets for a host.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
}
