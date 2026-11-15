# Keep remote access responsive when applications exhaust memory.
# The kernel OOM killer is often too late to prevent prolonged reclaim stalls.
{
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 10;
    freeSwapThreshold = 20;
  };

  # Lower the chance of the SSH daemon being selected by the kernel OOM
  # killer. This does not reserve memory for new sessions.
  systemd.services.sshd.serviceConfig.OOMScoreAdjust = -900;
}
