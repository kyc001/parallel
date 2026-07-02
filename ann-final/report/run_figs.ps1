$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

micromamba run -n test python .\gen_final_figs.py
micromamba run -n test python .\gen_adaptive_fig.py
