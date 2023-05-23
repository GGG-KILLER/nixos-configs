{...}: {
  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };
}
