Traceback (most recent call last):
  File "/usr/local/bin/pssh", line 106, in <module>
    opts, args = parse_args()
  File "/usr/local/bin/pssh", line 49, in parse_args
    parser = option_parser()
  File "/usr/local/bin/pssh", line 31, in option_parser
    parser = common_parser()
  File "/usr/local/lib/python3.9/site-packages/psshlib/cli.py", line 22, in common_parser
    version=version.VERSION)
AttributeError: module 'version' has no attribute 'VERSION'

Authorized users only. All activities may be monitored and reported.

Authorized users only. All activities may be monitored and reported.
scp: /home/s2413575/ann/files: No such file or directory
Traceback (most recent call last):
  File "/usr/local/bin/pscp", line 92, in <module>
    opts, args = parse_args()
  File "/usr/local/bin/pscp", line 39, in parse_args
    parser = option_parser()
  File "/usr/local/bin/pscp", line 28, in option_parser
    parser = common_parser()
  File "/usr/local/lib/python3.9/site-packages/psshlib/cli.py", line 22, in common_parser
    version=version.VERSION)
AttributeError: module 'version' has no attribute 'VERSION'
load data /anndata/DEEP100K.query.fbin
dimension: 96  number:10000  size_per_element:4
load data /anndata/DEEP100K.gt.query.100k.top100.bin
dimension: 100  number:10000  size_per_element:4
load data /anndata/DEEP100K.base.100k.fbin
dimension: 96  number:100000  size_per_element:4
[PQ] Building index: M=8, dsub=12, ksub=256, niter=20
[PQ] Training sub-segment 1/8...
[PQ] Training sub-segment 2/8...
[PQ] Training sub-segment 3/8...
[PQ] Training sub-segment 4/8...
[PQ] Training sub-segment 5/8...
[PQ] Training sub-segment 6/8...
[PQ] Training sub-segment 7/8...
[PQ] Training sub-segment 8/8...
[PQ] Index built.
rm: cannot remove '/home/s2413575/files/': No such file or directory
