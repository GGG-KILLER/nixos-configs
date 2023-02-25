{...}: {
  boot.cleanTmpDir = true;

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };
}
