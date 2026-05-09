	.file	"manual_vs_autovec.cc"
 # GNU C++17 (Rev3, Built by MSYS2 project) version 14.2.0 (x86_64-w64-mingw32)
 #	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

 # warning: MPFR header version 4.2.1 differs from library version 4.2.2.
 # GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
 # options passed: -mavx2 -mfma -mtune=generic -march=nocona -O3 -std=c++17 -fopt-info-vec-optimized -fopt-info-vec-missed
	.text
	.p2align 4
	.def	_ZN12_GLOBAL__N_124ip_distance_scalar_novecEPKfS1_i;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZN12_GLOBAL__N_124ip_distance_scalar_novecEPKfS1_i
_ZN12_GLOBAL__N_124ip_distance_scalar_novecEPKfS1_i:
.LFB9650:
	.seh_endprologue
 # analysis\manual_vs_autovec.cc:24:     for (int i = 0; i < d; ++i) {
	testl	%r8d, %r8d	 # d
	jle	.L4	 #,
	movslq	%r8d, %r8	 # d, _35
	xorl	%eax, %eax	 # ivtmp.330
 # analysis\manual_vs_autovec.cc:23:     float sum = 0.0f;
	vxorps	%xmm1, %xmm1, %xmm1	 # sum
	salq	$2, %r8	 #, _34
	.p2align 5
	.p2align 4
	.p2align 3
.L3:
 # analysis\manual_vs_autovec.cc:25:         sum += x[i] * y[i];
	vmovss	(%rcx,%rax), %xmm0	 # MEM[(const float *)x_13(D) + ivtmp.330_37 * 1], MEM[(const float *)x_13(D) + ivtmp.330_37 * 1]
	vmulss	(%rdx,%rax), %xmm0, %xmm0	 # MEM[(const float *)y_14(D) + ivtmp.330_37 * 1], MEM[(const float *)x_13(D) + ivtmp.330_37 * 1], _7
 # analysis\manual_vs_autovec.cc:24:     for (int i = 0; i < d; ++i) {
	addq	$4, %rax	 #, ivtmp.330
 # analysis\manual_vs_autovec.cc:25:         sum += x[i] * y[i];
	vaddss	%xmm0, %xmm1, %xmm1	 # _7, sum, sum
 # analysis\manual_vs_autovec.cc:24:     for (int i = 0; i < d; ++i) {
	cmpq	%rax, %r8	 # ivtmp.330, _34
	jne	.L3	 #,
 # analysis\manual_vs_autovec.cc:27:     return 1.0f - sum;
	vmovss	.LC1(%rip), %xmm0	 #, tmp112
	vsubss	%xmm1, %xmm0, %xmm0	 # sum, tmp112, <retval>
 # analysis\manual_vs_autovec.cc:28: }
	ret	
	.p2align 4,,10
	.p2align 3
.L4:
 # analysis\manual_vs_autovec.cc:24:     for (int i = 0; i < d; ++i) {
	vmovss	.LC1(%rip), %xmm0	 #, <retval>
 # analysis\manual_vs_autovec.cc:28: }
	ret	
	.seh_endproc
	.p2align 4
	.def	_ZN12_GLOBAL__N_116ip_distance_autoEPKfS1_i;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZN12_GLOBAL__N_116ip_distance_autoEPKfS1_i
_ZN12_GLOBAL__N_116ip_distance_autoEPKfS1_i:
.LFB9651:
	.seh_endprologue
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	testl	%r8d, %r8d	 # d
	jle	.L14	 #,
	leal	-1(%r8), %eax	 #, _40
	cmpl	$6, %eax	 #, _40
	jbe	.L15	 #,
	movl	%r8d, %r9d	 # d, bnd.337_43
	xorl	%eax, %eax	 # ivtmp.366
 # analysis\manual_vs_autovec.cc:34:     float sum = 0.0f;
	vxorps	%xmm1, %xmm1, %xmm1	 # sum
	shrl	$3, %r9d	 #,
	salq	$5, %r9	 #, _120
	.p2align 4
	.p2align 3
.L10:
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmovups	(%rdx,%rax), %ymm0	 # MEM <const vector(8) float> [(const float *)y_14(D) + ivtmp.366_76 * 1], vect__6.345_53
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmulps	(%rcx,%rax), %ymm0, %ymm0	 # MEM <const vector(8) float> [(const float *)x_13(D) + ivtmp.366_76 * 1], vect__6.345_53, vect__7.346
	addq	$32, %rax	 #, ivtmp.366
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_sum_15.347, sum, stmp_sum_15.347
	vshufps	$85, %xmm0, %xmm0, %xmm3	 #, tmp173, tmp173, stmp_sum_15.347
	vshufps	$255, %xmm0, %xmm0, %xmm2	 #, tmp173, tmp173, stmp_sum_15.347
	vaddss	%xmm3, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347
	vunpckhps	%xmm0, %xmm0, %xmm3	 # tmp173, tmp173, stmp_sum_15.347
	vextractf128	$0x1, %ymm0, %xmm0	 # vect__7.346, tmp177
	vaddss	%xmm3, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347
	vshufps	$85, %xmm0, %xmm0, %xmm2	 #, tmp177, tmp177, stmp_sum_15.347
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347
	vunpckhps	%xmm0, %xmm0, %xmm2	 # tmp177, tmp177, stmp_sum_15.347
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vshufps	$255, %xmm0, %xmm0, %xmm0	 #, tmp177, tmp177, stmp_sum_15.347_69
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_sum_15.347, stmp_sum_15.347, stmp_sum_15.347_68
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_sum_15.347_69, stmp_sum_15.347_68, sum
	cmpq	%r9, %rax	 # _120, ivtmp.366
	jne	.L10	 #,
	movl	%r8d, %eax	 # d, tmp.351
	andl	$-8, %eax	 #, tmp.351
	movl	%eax, %r9d	 # tmp.351,
	cmpl	%eax, %r8d	 # tmp.351, d
	je	.L21	 #,
	vzeroupper
.L9:
	movl	%r8d, %r10d	 # d, niters.348
	subl	%r9d, %r10d	 # niters_vector_mult_vf.338, niters.348
	leal	-1(%r10), %r11d	 #, _91
	cmpl	$2, %r11d	 #, _91
	jbe	.L12	 #,
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmovups	(%rdx,%r9,4), %xmm0	 # MEM <const vector(4) float> [(const float *)vectp_y.356_104], vect__23.357_109
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmulps	(%rcx,%r9,4), %xmm0, %xmm0	 # MEM <const vector(4) float> [(const float *)vectp_x.353_98], vect__23.357_109, vect__22.358
	movl	%r10d, %r9d	 # niters.348, niters_vector_mult_vf.350_95
	andl	$-4, %r9d	 #, niters_vector_mult_vf.350_95
	addl	%r9d, %eax	 # niters_vector_mult_vf.350_95, tmp.351
	andl	$3, %r10d	 #, niters.348
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_sum_18.359, sum, stmp_sum_18.359
	vshufps	$85, %xmm0, %xmm0, %xmm2	 #, vect__22.358, vect__22.358, stmp_sum_18.359
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_sum_18.359, stmp_sum_18.359, stmp_sum_18.359
	vunpckhps	%xmm0, %xmm0, %xmm2	 # vect__22.358, vect__22.358, stmp_sum_18.359
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vshufps	$255, %xmm0, %xmm0, %xmm0	 #, vect__22.358, vect__22.358, stmp_sum_18.359_117
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_sum_18.359, stmp_sum_18.359, stmp_sum_18.359_116
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_sum_18.359_117, stmp_sum_18.359_116, sum
	je	.L11	 #,
.L12:
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	movslq	%eax, %r9	 # tmp.351, _2
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmovss	(%rcx,%r9,4), %xmm4	 # *_4, tmp204
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	leaq	0(,%r9,4), %r10	 #, _3
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vfmadd231ss	(%rdx,%r9,4), %xmm4, %xmm1	 # *_6, tmp204, sum
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	leal	1(%rax), %r9d	 #, i_28
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	cmpl	%r9d, %r8d	 # i_28, d
	jle	.L11	 #,
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	addl	$2, %eax	 #, i_106
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmovss	4(%rdx,%r10), %xmm5	 # *_17, tmp205
	vfmadd231ss	4(%rcx,%r10), %xmm5, %xmm1	 # *_23, tmp205, sum
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	cmpl	%eax, %r8d	 # i_106, d
	jle	.L11	 #,
 # analysis\manual_vs_autovec.cc:36:         sum += x[i] * y[i];
	vmovss	8(%rcx,%r10), %xmm5	 # *_80, tmp206
	vfmadd231ss	8(%rdx,%r10), %xmm5, %xmm1	 # *_82, tmp206, sum
.L11:
 # analysis\manual_vs_autovec.cc:38:     return 1.0f - sum;
	vmovss	.LC1(%rip), %xmm0	 #, tmp194
	vsubss	%xmm1, %xmm0, %xmm0	 # sum, tmp194, <retval>
.L7:
 # analysis\manual_vs_autovec.cc:39: }
	ret	
	.p2align 4,,10
	.p2align 3
.L14:
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	vmovss	.LC1(%rip), %xmm0	 #, <retval>
 # analysis\manual_vs_autovec.cc:39: }
	ret	
	.p2align 4,,10
	.p2align 3
.L21:
	vzeroupper
 # analysis\manual_vs_autovec.cc:38:     return 1.0f - sum;
	vmovss	.LC1(%rip), %xmm0	 #, tmp194
	vsubss	%xmm1, %xmm0, %xmm0	 # sum, tmp194, <retval>
	jmp	.L7	 #
.L15:
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	xorl	%r9d, %r9d	 #
 # analysis\manual_vs_autovec.cc:35:     for (int i = 0; i < d; ++i) {
	xorl	%eax, %eax	 # tmp.351
 # analysis\manual_vs_autovec.cc:34:     float sum = 0.0f;
	vxorps	%xmm1, %xmm1, %xmm1	 # sum
	jmp	.L9	 #
	.seh_endproc
	.p2align 4
	.def	_ZN12_GLOBAL__N_118ip_distance_manualEPKfS1_i;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZN12_GLOBAL__N_118ip_distance_manualEPKfS1_i
_ZN12_GLOBAL__N_118ip_distance_manualEPKfS1_i:
.LFB9652:
	.seh_endprologue
 # analysis\manual_vs_autovec.cc:41: float ip_distance_manual(const float* x, const float* y, int d) {
	movq	%rcx, %r9	 # tmp265, x
	movq	%rdx, %r10	 # tmp266, y
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	cmpl	$31, %r8d	 #, d
	jle	.L30	 #,
	movq	%rcx, %rax	 # x, ivtmp.396
 # analysis\../flat_scan_avx2.h:30:     __m256 sum3 = _mm256_setzero_ps();
	vxorps	%xmm3, %xmm3, %xmm3	 # sum3
	leal	-32(%r8), %r11d	 #, _164
	movl	%r8d, %ecx	 # d, _150
 # analysis\../flat_scan_avx2.h:29:     __m256 sum2 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm2	 #, sum2
	shrl	$5, %ecx	 #, _150
 # analysis\../flat_scan_avx2.h:28:     __m256 sum1 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm0	 # tmp22, sum1
 # analysis\../flat_scan_avx2.h:27:     __m256 sum0 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm1	 # tmp20, sum0
	subl	$1, %ecx	 #, _195
	salq	$7, %rcx	 #, _196
	leaq	128(%r9,%rcx), %rcx	 #, _95
	.p2align 6
	.p2align 4
	.p2align 3
.L24:
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	(%rax), %ymm4	 # MEM[(__m256_u * {ref-all})_183], tmp270
	vmovups	32(%rax), %ymm5	 # MEM[(__m256_u * {ref-all})_183 + 32B], tmp271
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	subq	$-128, %rax	 #, ivtmp.396
	subq	$-128, %rdx	 #, ivtmp.397
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vfmadd231ps	-128(%rdx), %ymm4, %ymm1	 # MEM[(__m256_u * {ref-all})_62], tmp270, sum0
	vfmadd231ps	-96(%rdx), %ymm5, %ymm0	 # MEM[(__m256_u * {ref-all})_62 + 32B], tmp271, sum1
	vmovups	-64(%rax), %ymm4	 # MEM[(__m256_u * {ref-all})_183 + 64B], tmp272
	vmovups	-32(%rax), %ymm5	 # MEM[(__m256_u * {ref-all})_183 + 96B], tmp273
	vfmadd231ps	-64(%rdx), %ymm4, %ymm2	 # MEM[(__m256_u * {ref-all})_62 + 64B], tmp272, sum2
	vfmadd231ps	-32(%rdx), %ymm5, %ymm3	 # MEM[(__m256_u * {ref-all})_62 + 96B], tmp273, sum3
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	cmpq	%rax, %rcx	 # ivtmp.396, _95
	jne	.L24	 #,
	movl	%r11d, %edx	 # _164, _164
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:149:   return (__m256) ((__v8sf)__A + (__v8sf)__B);
	vaddps	%ymm3, %ymm2, %ymm2	 # sum3, sum2, _208
	andl	$-32, %edx	 #, _164
	leal	32(%rdx), %eax	 #, tmp.380
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	addl	$39, %edx	 #, _210
.L23:
	cmpl	%edx, %r8d	 # _210, d
	jle	.L25	 #,
 # analysis\../flat_scan_avx2.h:52:         __m256 vx = _mm256_loadu_ps(x + i);
	movslq	%eax, %rdx	 # tmp.380, _157
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	(%r9,%rdx,4), %ymm3	 # MEM[(__m256_u * {ref-all})_155], tmp275
 # analysis\../flat_scan_avx2.h:52:         __m256 vx = _mm256_loadu_ps(x + i);
	leaq	0(,%rdx,4), %rcx	 #, _156
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vfmadd231ps	(%r10,%rdx,4), %ymm3, %ymm1	 # MEM[(__m256_u * {ref-all})_153], tmp275, sum0
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	leal	15(%rax), %edx	 #, _149
	cmpl	%edx, %r8d	 # _149, d
	jle	.L26	 #,
	leal	23(%rax), %edx	 #, _138
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	32(%r9,%rcx), %ymm3	 # MEM[(__m256_u * {ref-all})_144], tmp276
	vfmadd231ps	32(%r10,%rcx), %ymm3, %ymm1	 # MEM[(__m256_u * {ref-all})_142], tmp276, sum0
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	cmpl	%edx, %r8d	 # _138, d
	jle	.L26	 #,
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	64(%r9,%rcx), %ymm3	 # MEM[(__m256_u * {ref-all})_44], tmp277
	vfmadd231ps	64(%r10,%rcx), %ymm3, %ymm1	 # MEM[(__m256_u * {ref-all})_46], tmp277, sum0
.L26:
	leal	-8(%r8), %edx	 #, _243
	leal	7(%rax), %ecx	 #, _227
	subl	%eax, %edx	 # tmp.380, _225
	andl	$-8, %edx	 #, _233
	cmpl	%ecx, %r8d	 # _227, d
	movl	$0, %ecx	 #, tmp242
	cmovle	%ecx, %edx	 # _233,, tmp242, _233
	leal	8(%rax,%rdx), %eax	 #, tmp.380
.L25:
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:149:   return (__m256) ((__v8sf)__A + (__v8sf)__B);
	vaddps	%ymm1, %ymm0, %ymm0	 # sum0, sum1, _53
	vaddps	%ymm2, %ymm0, %ymm0	 # _208, _53, _54
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:272:   return (__m256) __builtin_ia32_haddps256 ((__v8sf)__X, (__v8sf)__Y);
	vhaddps	%ymm0, %ymm0, %ymm0	 # _54, _54, tmp245
	vhaddps	%ymm0, %ymm0, %ymm0	 # tmp245, tmp245, tmp246
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:1472:   return (__m128) __builtin_ia32_ps_ps256 ((__v8sf)__A);
	vmovaps	%xmm0, %xmm1	 # tmp246, tmp247
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:526:   return (__m128) __builtin_ia32_vextractf128_ps256 ((__v8sf)__X, __N);
	vextractf128	$0x1, %ymm0, %xmm0	 # tmp246, tmp249
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/xmmintrin.h:136:   return (__m128) __builtin_ia32_addss ((__v4sf)__A, (__v4sf)__B);
	vaddss	%xmm0, %xmm1, %xmm1	 # tmp249, tmp247, tmp251
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%eax, %r8d	 # tmp.380, d
	jle	.L27	 #,
	movl	%r8d, %edx	 # d, niters.377
	subl	%eax, %edx	 # tmp.380, niters.377
	leal	-1(%rdx), %ecx	 #, _193
	cmpl	$2, %ecx	 #, _193
	jbe	.L28	 #,
	movslq	%eax, %rcx	 # tmp.380, _185
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovups	(%r9,%rcx,4), %xmm0	 # MEM <const vector(4) float> [(const float *)vectp.382_186], vect__65.383_181
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmulps	(%r10,%rcx,4), %xmm0, %xmm0	 # MEM <const vector(4) float> [(const float *)vectp.385_180], vect__65.383_181, vect__68.387
	movl	%edx, %ecx	 # niters.377, niters_vector_mult_vf.379_189
	andl	$-4, %ecx	 #, niters_vector_mult_vf.379_189
	addl	%ecx, %eax	 # niters_vector_mult_vf.379_189, tmp.380
	andl	$3, %edx	 #, niters.377
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_dot_70.388, dot, stmp_dot_70.388
	vshufps	$85, %xmm0, %xmm0, %xmm2	 #, vect__68.387, vect__68.387, stmp_dot_70.388
	vaddss	%xmm1, %xmm2, %xmm2	 # stmp_dot_70.388, stmp_dot_70.388, stmp_dot_70.388
	vunpckhps	%xmm0, %xmm0, %xmm1	 # vect__68.387, vect__68.387, stmp_dot_70.388
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vshufps	$255, %xmm0, %xmm0, %xmm0	 #, vect__68.387, vect__68.387, stmp_dot_70.388_167
	vaddss	%xmm2, %xmm1, %xmm1	 # stmp_dot_70.388, stmp_dot_70.388, stmp_dot_70.388_168
	vaddss	%xmm0, %xmm1, %xmm1	 # stmp_dot_70.388_167, stmp_dot_70.388_168, dot
	je	.L27	 #,
.L28:
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	movslq	%eax, %rdx	 # tmp.380, _63
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	(%r9,%rdx,4), %xmm3	 # *_65, tmp280
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	leaq	0(,%rdx,4), %rcx	 #, _64
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vfmadd231ss	(%r10,%rdx,4), %xmm3, %xmm1	 # *_67, tmp280, dot
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	leal	1(%rax), %edx	 #, i_179
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%edx, %r8d	 # i_179, d
	jle	.L27	 #,
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	addl	$2, %eax	 #, i_160
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	4(%r10,%rcx), %xmm3	 # *_235, tmp281
	vfmadd231ss	4(%r9,%rcx), %xmm3, %xmm1	 # *_218, tmp281, dot
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%eax, %r8d	 # i_160, d
	jle	.L27	 #,
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	8(%r10,%rcx), %xmm3	 # *_203, tmp282
	vfmadd231ss	8(%r9,%rcx), %xmm3, %xmm1	 # *_205, tmp282, dot
.L27:
 # analysis\../flat_scan_avx2.h:65:     return 1.0f - dot;
	vmovss	.LC1(%rip), %xmm0	 #, tmp264
	vsubss	%xmm1, %xmm0, %xmm0	 # dot, tmp264, _72
	vzeroupper
 # analysis\manual_vs_autovec.cc:47: }
	ret	
	.p2align 4,,10
	.p2align 3
.L30:
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	vxorps	%xmm2, %xmm2, %xmm2	 # _208
	movl	$7, %edx	 #, _210
 # analysis\../flat_scan_avx2.h:32:     int i = 0;
	xorl	%eax, %eax	 # tmp.380
 # analysis\../flat_scan_avx2.h:28:     __m256 sum1 = _mm256_setzero_ps();
	vmovaps	%ymm2, %ymm0	 #, sum1
 # analysis\../flat_scan_avx2.h:27:     __m256 sum0 = _mm256_setzero_ps();
	vmovaps	%ymm2, %ymm1	 # tmp20, sum0
	jmp	.L23	 #
	.seh_endproc
	.section .rdata,"dr"
.LC3:
	.ascii "impossible\12\0"
	.text
	.p2align 4
	.def	_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii
_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii:
.LFB9998:
	pushq	%r14	 #
	.seh_pushreg	%r14
	pushq	%r13	 #
	.seh_pushreg	%r13
	pushq	%r12	 #
	.seh_pushreg	%r12
	pushq	%rbp	 #
	.seh_pushreg	%rbp
	pushq	%rdi	 #
	.seh_pushreg	%rdi
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$48, %rsp	 #,
	.seh_stackalloc	48
	.seh_endprologue
 # analysis\manual_vs_autovec.cc:50: double BenchmarkKernel(Fn fn, const std::vector<float>& a, const std::vector<float>& b,
	movl	144(%rsp), %esi	 # repeat, repeat
	movq	%rcx, %rdi	 # tmp128, fn
	movq	%rdx, %rbp	 # tmp129, a
	movq	%r8, %r12	 # tmp130, b
	movl	%r9d, %r13d	 # tmp131, d
 # analysis\manual_vs_autovec.cc:52:     volatile float sink = 0.0f;
	movl	$0x00000000, 44(%rsp)	 #, sink
 # analysis\manual_vs_autovec.cc:53:     const auto start = std::chrono::high_resolution_clock::now();
	call	_ZNSt6chrono3_V212system_clock3nowEv	 #
	movq	%rax, %r14	 # tmp132, start
 # analysis\manual_vs_autovec.cc:54:     for (int r = 0; r < repeat; ++r) {
	testl	%esi, %esi	 # repeat
	jle	.L33	 #,
 # analysis\manual_vs_autovec.cc:54:     for (int r = 0; r < repeat; ++r) {
	xorl	%ebx, %ebx	 # r
	.p2align 4
	.p2align 3
.L34:
 # analysis\manual_vs_autovec.cc:55:         sink += fn(a.data(), b.data(), d);
	movq	(%r12), %rdx	 # b_21(D)->D.105400._M_impl.D.104740._M_start, b_21(D)->D.105400._M_impl.D.104740._M_start
	movq	0(%rbp), %rcx	 # a_22(D)->D.105400._M_impl.D.104740._M_start, a_22(D)->D.105400._M_impl.D.104740._M_start
	movl	%r13d, %r8d	 # d,
 # analysis\manual_vs_autovec.cc:54:     for (int r = 0; r < repeat; ++r) {
	addl	$1, %ebx	 #, r
 # analysis\manual_vs_autovec.cc:55:         sink += fn(a.data(), b.data(), d);
	call	*%rdi	 # fn
	vmovaps	%xmm0, %xmm1	 #, tmp133
 # analysis\manual_vs_autovec.cc:55:         sink += fn(a.data(), b.data(), d);
	vmovss	44(%rsp), %xmm0	 # sink, sink.25_1
	vaddss	%xmm1, %xmm0, %xmm0	 # tmp133, sink.25_1, _2
	vmovss	%xmm0, 44(%rsp)	 # _2, sink
 # analysis\manual_vs_autovec.cc:54:     for (int r = 0; r < repeat; ++r) {
	cmpl	%ebx, %esi	 # r, repeat
	jne	.L34	 #,
.L33:
 # analysis\manual_vs_autovec.cc:57:     const auto stop = std::chrono::high_resolution_clock::now();
	call	_ZNSt6chrono3_V212system_clock3nowEv	 #
 # analysis\manual_vs_autovec.cc:58:     if (sink == 123456.0f) {
	vmovss	44(%rsp), %xmm0	 # sink, sink.27_3
 # analysis\manual_vs_autovec.cc:58:     if (sink == 123456.0f) {
	vucomiss	.LC2(%rip), %xmm0	 #, sink.27_3
 # analysis\manual_vs_autovec.cc:57:     const auto stop = std::chrono::high_resolution_clock::now();
	movq	%rax, %rbx	 # tmp134, stop
 # analysis\manual_vs_autovec.cc:58:     if (sink == 123456.0f) {
	jp	.L35	 #,
	je	.L39	 #,
.L35:
	vxorps	%xmm1, %xmm1, %xmm1	 # tmp136
 # C:/msys64/mingw64/include/c++/14.2.0/bits/chrono.h:716: 	return __cd(__cd(__lhs).count() - __cd(__rhs).count());
	subq	%r14, %rbx	 # start, _32
 # C:/msys64/mingw64/include/c++/14.2.0/bits/chrono.h:201: 	    return _ToDur(static_cast<__to_rep>(__d.count()));
	vcvtsi2sdq	%rbx, %xmm1, %xmm0	 # _32, tmp136, tmp137
 # analysis\manual_vs_autovec.cc:62:            static_cast<double>(repeat);
	vcvtsi2sdl	%esi, %xmm1, %xmm1	 # repeat, tmp136, tmp138
 # analysis\manual_vs_autovec.cc:62:            static_cast<double>(repeat);
	vdivsd	%xmm1, %xmm0, %xmm0	 # _4, _29, <retval>
 # analysis\manual_vs_autovec.cc:63: }
	addq	$48, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
	popq	%rdi	 #
	popq	%rbp	 #
	popq	%r12	 #
	popq	%r13	 #
	popq	%r14	 #
	ret	
.L39:
 # analysis\manual_vs_autovec.cc:59:         std::fprintf(stderr, "impossible\n");
	movl	$2, %ecx	 #,
	call	*__imp___acrt_iob_func(%rip)	 #
 # analysis\manual_vs_autovec.cc:59:         std::fprintf(stderr, "impossible\n");
	leaq	.LC3(%rip), %rdx	 #, tmp123
 # analysis\manual_vs_autovec.cc:59:         std::fprintf(stderr, "impossible\n");
	movq	%rax, %rcx	 # tmp135, _14
 # analysis\manual_vs_autovec.cc:59:         std::fprintf(stderr, "impossible\n");
	call	__mingw_fprintf	 #
	jmp	.L35	 #
	.seh_endproc
	.p2align 4
	.def	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0
_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0:
.LFB10455:
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$40, %rsp	 #,
	.seh_stackalloc	40
	.seh_endprologue
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:668:     operator<<(basic_ostream<char, _Traits>& __out, const char* __s)
	movq	%rcx, %rsi	 # tmp115, __out
	movq	%rdx, %rbx	 # tmp116, __s
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:670:       if (!__s)
	testq	%rdx, %rdx	 # __s
	je	.L42	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/char_traits.h:391: 	return __builtin_strlen(__s);
	movq	%rdx, %rcx	 # __s,
	call	strlen	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movq	%rbx, %rdx	 # __s,
	movq	%rsi, %rcx	 # __out,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/char_traits.h:391: 	return __builtin_strlen(__s);
	movq	%rax, %r8	 #, tmp117
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:676:     }
	addq	$40, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	jmp	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
.L42:
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:671: 	__out.setstate(ios_base::badbit);
	movq	(%rcx), %rax	 # __out_2(D)->_vptr.basic_ostream, __out_2(D)->_vptr.basic_ostream
	addq	-24(%rax), %rsi	 # MEM[(long long int *)_9 + -24B], __out
 # C:/msys64/mingw64/include/c++/14.2.0/bits/ios_base.h:187:   { return _Ios_Iostate(static_cast<int>(__a) | static_cast<int>(__b)); }
	movl	32(%rsi), %edx	 # MEM[(const struct basic_ios *)_12].D.57959._M_streambuf_state, _14
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:671: 	__out.setstate(ios_base::badbit);
	movq	%rsi, %rcx	 # __out, _12
 # C:/msys64/mingw64/include/c++/14.2.0/bits/ios_base.h:187:   { return _Ios_Iostate(static_cast<int>(__a) | static_cast<int>(__b)); }
	orl	$1, %edx	 #, _14
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:676:     }
	addq	$40, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_ios.h:162:       { this->clear(this->rdstate() | __state); }
	jmp	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate	 #
	.seh_endproc
	.section .rdata,"dr"
	.align 8
.LC4:
	.ascii "cannot create std::vector larger than max_size()\0"
	.text
	.align 2
	.p2align 4
	.def	_ZNSt6vectorIfSaIfEEC1EyRKS0_.isra.0;	.scl	3;	.type	32;	.endef
	.seh_proc	_ZNSt6vectorIfSaIfEEC1EyRKS0_.isra.0
_ZNSt6vectorIfSaIfEEC1EyRKS0_.isra.0:
.LFB10456:
	pushq	%r12	 #
	.seh_pushreg	%r12
	pushq	%rbp	 #
	.seh_pushreg	%rbp
	pushq	%rdi	 #
	.seh_pushreg	%rdi
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$32, %rsp	 #,
	.seh_stackalloc	32
	.seh_endprologue
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1919: 	if (__n > _S_max_size(_Tp_alloc_type(__a)))
	movq	%rdx, %rax	 # __n, tmp126
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:556:       vector(size_type __n, const allocator_type& __a = allocator_type())
	movq	%rcx, %rbx	 # tmp123, this
	movq	%rdx, %rsi	 # tmp124, __n
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1919: 	if (__n > _S_max_size(_Tp_alloc_type(__a)))
	shrq	$61, %rax	 #, tmp126
	jne	.L50	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	vpxor	%xmm0, %xmm0, %xmm0	 # tmp113
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	movq	$0, 16(%rcx)	 #, MEM[(struct _Vector_impl_data *)this_1(D)]._M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	vmovdqu	%xmm0, (%rcx)	 # tmp113, MEM <vector(2) long long unsigned int> [(float * *)this_1(D)]
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:380: 	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
	testq	%rdx, %rdx	 # __n
	je	.L51	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:151: 	return static_cast<_Tp*>(_GLIBCXX_OPERATOR_NEW(__n * sizeof(_Tp)));
	leaq	0(,%rdx,4), %rbp	 #, _26
	movq	%rbp, %rcx	 # _26,
	call	_Znwy	 #
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_algobase.h:1146:       if (__n <= 0)
	subq	$1, %rsi	 #, __n
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:400: 	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
	leaq	(%rax,%rbp), %r12	 #, _15
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:398: 	this->_M_impl._M_start = this->_M_allocate(__n);
	movq	%rax, (%rbx)	 # tmp114, MEM[(struct _Vector_base *)this_1(D)]._M_impl.D.104740._M_start
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:151: 	return static_cast<_Tp*>(_GLIBCXX_OPERATOR_NEW(__n * sizeof(_Tp)));
	movq	%rax, %rdi	 # tmp125, tmp114
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:667: 	      ++__first;
	leaq	4(%rax), %rcx	 #, __first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:400: 	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
	movq	%r12, 16(%rbx)	 # _15, MEM[(struct _Vector_base *)this_1(D)]._M_impl.D.104740._M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_construct.h:119:       ::new((void*)__p) _Tp(std::forward<_Args>(__args)...);
	movl	$0x00000000, (%rax)	 #, *_27
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_algobase.h:1146:       if (__n <= 0)
	je	.L46	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_algobase.h:952: 	*__first = __tmp;
	leaq	-4(%rbp), %r8	 #,
	xorl	%edx, %edx	 #
	call	memset	 #
	leaq	-4(%rax,%r12), %rcx	 #, _44
	subq	%rdi, %rcx	 # tmp114, __first
.L46:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1719: 	this->_M_impl._M_finish =
	movq	%rcx, 8(%rbx)	 # __first, *this_1(D).D.105400._M_impl.D.104740._M_finish
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:558:       { _M_default_initialize(__n); }
	addq	$32, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
	popq	%rdi	 #
	popq	%rbp	 #
	popq	%r12	 #
	ret	
.L51:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:400: 	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
	xorl	%eax, %eax	 #
	movq	%rax, (%rcx)	 #, MEM[(struct _Vector_base *)this_1(D)]._M_impl.D.104740._M_start
	movq	%rax, 16(%rcx)	 #, MEM[(struct _Vector_base *)this_1(D)]._M_impl.D.104740._M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:380: 	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
	xorl	%ecx, %ecx	 # __first
	jmp	.L46	 #
.L50:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1920: 	  __throw_length_error(
	leaq	.LC4(%rip), %rcx	 #, tmp112
	call	_ZSt20__throw_length_errorPKc	 #
	nop	
	.seh_endproc
	.section .rdata,"dr"
.LC26:
	.ascii "arch=\0"
.LC27:
	.ascii "\12\0"
.LC28:
	.ascii "d=\0"
.LC29:
	.ascii " repeat=\0"
.LC30:
	.ascii "scalar_novec_ns=\0"
.LC31:
	.ascii "autovec_ns=\0"
.LC32:
	.ascii "manual_simd_ns=\0"
.LC33:
	.ascii "autovec_speedup_vs_scalar=\0"
.LC34:
	.ascii "manual_speedup_vs_scalar=\0"
.LC35:
	.ascii "manual_speedup_vs_autovec=\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
.LFB9655:
	pushq	%r15	 #
	.seh_pushreg	%r15
	pushq	%r14	 #
	.seh_pushreg	%r14
	pushq	%r13	 #
	.seh_pushreg	%r13
	pushq	%r12	 #
	.seh_pushreg	%r12
	pushq	%rbp	 #
	.seh_pushreg	%rbp
	pushq	%rdi	 #
	.seh_pushreg	%rdi
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$296, %rsp	 #,
	.seh_stackalloc	296
	vmovups	%xmm6, 160(%rsp)	 #,
	.seh_savexmm	%xmm6, 160
	vmovups	%xmm7, 176(%rsp)	 #,
	.seh_savexmm	%xmm7, 176
	vmovups	%xmm8, 192(%rsp)	 #,
	.seh_savexmm	%xmm8, 192
	vmovups	%xmm9, 208(%rsp)	 #,
	.seh_savexmm	%xmm9, 208
	vmovups	%xmm10, 224(%rsp)	 #,
	.seh_savexmm	%xmm10, 224
	vmovups	%xmm11, 240(%rsp)	 #,
	.seh_savexmm	%xmm11, 240
	vmovups	%xmm12, 256(%rsp)	 #,
	.seh_savexmm	%xmm12, 256
	vmovups	%xmm13, 272(%rsp)	 #,
	.seh_savexmm	%xmm13, 272
	.seh_endprologue
 # analysis\manual_vs_autovec.cc:76:     const int d = (argc >= 2) ? std::atoi(argv[1]) : 96;
	movl	$96, %ebx	 #, iftmp.18_27
 # analysis\manual_vs_autovec.cc:77:     const int repeat = (argc >= 3) ? std::atoi(argv[2]) : 2000000;
	movl	$2000000, %ebp	 #, iftmp.19_17
 # analysis\manual_vs_autovec.cc:75: int main(int argc, char** argv) {
	movl	%ecx, %esi	 # tmp537, argc
	movq	%rdx, %rdi	 # tmp538, argv
	call	__main	 #
 # analysis\manual_vs_autovec.cc:76:     const int d = (argc >= 2) ? std::atoi(argv[1]) : 96;
	cmpl	$1, %esi	 #, argc
	jg	.L99	 #,
.L53:
 # analysis\manual_vs_autovec.cc:79:     std::vector<float> a(static_cast<size_t>(d));
	movslq	%ebx, %r14	 # iftmp.18_27, _3
	leaq	64(%rsp), %r12	 #, tmp534
 # analysis\manual_vs_autovec.cc:80:     std::vector<float> b(static_cast<size_t>(d));
	leaq	96(%rsp), %r13	 #, tmp536
 # analysis\manual_vs_autovec.cc:79:     std::vector<float> a(static_cast<size_t>(d));
	movq	%r14, %rdx	 # _3,
	movq	%r12, %rcx	 # tmp534,
.LEHB0:
	call	_ZNSt6vectorIfSaIfEEC1EyRKS0_.isra.0	 #
.LEHE0:
	movq	80(%rsp), %rax	 # MEM <float *> [(struct vector *)&a + 16B], a$_M_impl$D104740$_M_end_of_storage
 # analysis\manual_vs_autovec.cc:80:     std::vector<float> b(static_cast<size_t>(d));
	movq	%r14, %rdx	 # _3,
	movq	%r13, %rcx	 # tmp536,
 # analysis\manual_vs_autovec.cc:79:     std::vector<float> a(static_cast<size_t>(d));
	movq	64(%rsp), %rsi	 # MEM <float *> [(struct vector *)&a], a$D105400$_M_impl$D104740$_M_start
	movq	%rax, 56(%rsp)	 # a$_M_impl$D104740$_M_end_of_storage, %sfp
.LEHB1:
 # analysis\manual_vs_autovec.cc:80:     std::vector<float> b(static_cast<size_t>(d));
	call	_ZNSt6vectorIfSaIfEEC1EyRKS0_.isra.0	 #
.LEHE1:
	movq	96(%rsp), %rdi	 # MEM <float *> [(struct vector *)&b], b$D105400$_M_impl$D104740$_M_start
	movq	112(%rsp), %r15	 # MEM <float *> [(struct vector *)&b + 16B], b$_M_impl$D104740$_M_end_of_storage
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	testl	%ebx, %ebx	 # iftmp.18_27
	jle	.L54	 #,
	leal	-1(%rbx), %edx	 #, _158
	vxorps	%xmm10, %xmm10, %xmm10	 # tmp556
	movl	%ebx, %eax	 # iftmp.18_27, niters.448
	cmpl	$2, %edx	 #, _158
	jbe	.L73	 #,
	leaq	4(%rsi), %r8	 #, _160
	movq	%rdi, %rcx	 # b$D105400$_M_impl$D104740$_M_start, _161
	subq	%r8, %rcx	 # _160, _161
	cmpq	$24, %rcx	 #, _161
	jbe	.L73	 #,
	cmpl	$6, %edx	 #, _158
	jbe	.L74	 #,
	movl	$8, %ecx	 #, tmp243
	movl	%ebx, %edx	 # iftmp.18_27, bnd.425_207
	xorl	%eax, %eax	 # ivtmp.485
	vmovdqu	.LC6(%rip), %ymm3	 #, vect_vec_iv_.428
	vbroadcastss	.LC11(%rip), %ymm12	 #, tmp529
	vmovd	%ecx, %xmm9	 # tmp243, tmp242
	shrl	$3, %edx	 #,
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movl	$354224107, %ecx	 #, tmp247
	vmovd	%ecx, %xmm5	 # tmp247, tmp246
	movl	$1, %ecx	 #, tmp267
	salq	$5, %rdx	 #, _334
	vbroadcastss	.LC16(%rip), %ymm11	 #, tmp530
	vmovd	%ecx, %xmm8	 # tmp267, tmp266
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	$-1206451487, %ecx	 #, tmp275
	vpbroadcastd	%xmm9, %ymm9	 # tmp242, tmp242
	vmovd	%ecx, %xmm4	 # tmp275, tmp274
	movl	$89, %ecx	 #, tmp290
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vpbroadcastd	%xmm5, %ymm5	 # tmp246, tmp246
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovd	%ecx, %xmm7	 # tmp290, tmp289
	movl	$3, %ecx	 #, tmp295
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vpbroadcastd	%xmm8, %ymm8	 # tmp266, tmp266
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovd	%ecx, %xmm6	 # tmp295, tmp294
	vpbroadcastd	%xmm4, %ymm4	 # tmp274, tmp274
	vpbroadcastd	%xmm7, %ymm7	 # tmp289, tmp289
	vpbroadcastd	%xmm6, %ymm6	 # tmp294, tmp294
	.p2align 4
	.p2align 3
.L57:
	vmovdqa	%ymm3, %ymm1	 # vect_vec_iv_.428, vect_vec_iv_.428
	vpaddd	%ymm9, %ymm3, %ymm3	 # tmp242, vect_vec_iv_.428, vect_vec_iv_.428
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vpsrlq	$32, %ymm1, %ymm2	 #, vect_vec_iv_.428, tmp252
	vpmuldq	%ymm5, %ymm1, %ymm0	 # tmp246, vect_vec_iv_.428, tmp244
	vpmuldq	%ymm5, %ymm2, %ymm13	 # tmp246, tmp252, tmp248
	vpshufd	$245, %ymm0, %ymm0	 #, tmp244, tmp256
	vpblendd	$85, %ymm0, %ymm13, %ymm13	 #, tmp256, tmp248, vect_patt_16.429_216
	vpsrad	$3, %ymm13, %ymm13	 #, vect_patt_16.429_216, vect_patt_66.430_217
	vpslld	$1, %ymm13, %ymm0	 #, vect_patt_66.430_217, tmp259
	vpaddd	%ymm13, %ymm0, %ymm0	 # vect_patt_66.430_217, tmp259, tmp260
	vpslld	$5, %ymm0, %ymm0	 #, tmp260, tmp261
	vpaddd	%ymm13, %ymm0, %ymm0	 # vect_patt_66.430_217, tmp261, vect_patt_153.431_219
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vpmuldq	%ymm4, %ymm1, %ymm13	 # tmp274, vect_vec_iv_.428, tmp272
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vpsubd	%ymm0, %ymm1, %ymm0	 # vect_patt_153.431_219, vect_vec_iv_.428, vect_patt_144.432_220
	vpaddd	%ymm8, %ymm0, %ymm0	 # tmp266, vect_patt_144.432_220, vect__5.433_222
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtdq2ps	%ymm0, %ymm0	 # vect__5.433_222, vect__6.434_223
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulps	%ymm12, %ymm0, %ymm0	 # tmp529, vect__6.434_223, vect__7.435_225
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovups	%ymm0, (%rsi,%rax)	 # vect__7.435_225, MEM <vector(8) float> [(value_type &)a$D105400$_M_impl$D104740$_M_start_67 + ivtmp.485_337 * 1]
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vpmuldq	%ymm4, %ymm2, %ymm0	 # tmp274, tmp252, tmp276
	vpshufd	$245, %ymm13, %ymm2	 #, tmp272, tmp284
	vpblendd	$85, %ymm2, %ymm0, %ymm0	 #, tmp284, tmp276, vect_patt_130.438_230
	vpaddd	%ymm1, %ymm0, %ymm0	 # vect_vec_iv_.428, vect_patt_130.438_230, vect_patt_129.439_231
	vpsrad	$6, %ymm0, %ymm0	 #, vect_patt_129.439_231, vect_patt_128.440_232
	vpmulld	%ymm7, %ymm0, %ymm0	 # tmp289, vect_patt_128.440_232, vect_patt_126.441_234
	vpsubd	%ymm0, %ymm1, %ymm1	 # vect_patt_126.441_234, vect_vec_iv_.428, vect_patt_98.442_235
	vpaddd	%ymm6, %ymm1, %ymm1	 # tmp294, vect_patt_98.442_235, vect__10.443_237
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtdq2ps	%ymm1, %ymm1	 # vect__10.443_237, vect__11.444_238
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulps	%ymm11, %ymm1, %ymm1	 # tmp530, vect__11.444_238, vect__12.445_240
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovups	%ymm1, (%rdi,%rax)	 # vect__12.445_240, MEM <vector(8) float> [(value_type &)b$D105400$_M_impl$D104740$_M_start_138 + ivtmp.485_337 * 1]
	addq	$32, %rax	 #, ivtmp.485
	cmpq	%rax, %rdx	 # ivtmp.485, _334
	jne	.L57	 #,
	movl	%ebx, %ecx	 # iftmp.18_27, tmp.451
	andl	$-8, %ecx	 #, tmp.451
	movl	%ecx, %edx	 # tmp.451,
	cmpl	%ecx, %ebx	 # tmp.451, iftmp.18_27
	je	.L97	 #,
	movl	%ebx, %eax	 # iftmp.18_27, niters.448
	subl	%ecx, %eax	 # tmp.451, niters.448
	leal	-1(%rax), %r8d	 #, _270
	cmpl	$2, %r8d	 #, _270
	jbe	.L100	 #,
	vzeroupper
.L56:
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vpbroadcastd	.LC36(%rip), %xmm0	 #, tmp306
	vmovd	%ecx, %xmm6	 # tmp.451, tmp.451
	vpbroadcastd	%xmm6, %xmm1	 # tmp.451, _201
	vpaddd	.LC17(%rip), %xmm1, %xmm1	 #, _201, _280
	vpmuldq	%xmm0, %xmm1, %xmm2	 # tmp306, _280, tmp304
	vpsrlq	$32, %xmm1, %xmm3	 #, _280, tmp312
	vpmuldq	%xmm0, %xmm3, %xmm0	 # tmp306, tmp312, tmp308
	vpshufd	$245, %xmm2, %xmm2	 #, tmp304, tmp316
	vpblendd	$5, %xmm2, %xmm0, %xmm0	 #, tmp316, tmp308, vect_patt_131.453_285
	vpbroadcastd	.LC37(%rip), %xmm2	 #, tmp320
	vpsrad	$3, %xmm0, %xmm0	 #, vect_patt_131.453_285, vect_patt_147.454_286
	vpmulld	%xmm2, %xmm0, %xmm0	 # tmp320, vect_patt_147.454_286, vect_patt_132.455_288
	vpbroadcastd	.LC38(%rip), %xmm2	 #, tmp325
	vpsubd	%xmm0, %xmm1, %xmm0	 # vect_patt_132.455_288, _280, vect_patt_146.456_289
	vpaddd	%xmm2, %xmm0, %xmm0	 # tmp325, vect_patt_146.456_289, vect__187.457_291
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vbroadcastss	.LC11(%rip), %xmm2	 #, tmp330
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtdq2ps	%xmm0, %xmm0	 # vect__187.457_291, vect__188.458_292
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulps	%xmm2, %xmm0, %xmm0	 # tmp330, vect__188.458_292, vect__189.459_294
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vpbroadcastd	.LC39(%rip), %xmm2	 #, tmp333
	vpmuldq	%xmm2, %xmm1, %xmm4	 # tmp333, _280, tmp331
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovups	%xmm0, (%rsi,%rdx,4)	 # vect__189.459_294, MEM <vector(4) float> [(value_type &)vectp_a$D105400$_M_impl$D104740$_M_start.461_295]
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vpmuldq	%xmm2, %xmm3, %xmm0	 # tmp333, tmp312, tmp335
	vpshufd	$245, %xmm4, %xmm2	 #, tmp331, tmp343
	vpblendd	$5, %xmm2, %xmm0, %xmm0	 #, tmp343, tmp335, vect_patt_35.462_302
	vpbroadcastd	.LC40(%rip), %xmm2	 #, tmp348
	vpaddd	%xmm1, %xmm0, %xmm0	 # _280, vect_patt_35.462_302, vect_patt_31.463_303
	vpsrad	$6, %xmm0, %xmm0	 #, vect_patt_31.463_303, vect_patt_97.464_304
	vpmulld	%xmm2, %xmm0, %xmm0	 # tmp348, vect_patt_97.464_304, vect_patt_155.465_306
	vpsubd	%xmm0, %xmm1, %xmm0	 # vect_patt_155.465_306, _280, vect_patt_156.466_307
	vpbroadcastd	.LC41(%rip), %xmm1	 #, tmp353
	vpaddd	%xmm1, %xmm0, %xmm0	 # tmp353, vect_patt_156.466_307, vect__195.467_309
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vbroadcastss	.LC16(%rip), %xmm1	 #, tmp358
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtdq2ps	%xmm0, %xmm0	 # vect__195.467_309, vect__196.468_310
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulps	%xmm1, %xmm0, %xmm0	 # tmp358, vect__196.468_310, vect__197.469_312
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovups	%xmm0, (%rdi,%rdx,4)	 # vect__197.469_312, MEM <vector(4) float> [(value_type &)vectp_b$D105400$_M_impl$D104740$_M_start.471_313]
	movl	%eax, %edx	 # niters.448, niters_vector_mult_vf.450_274
	andl	$-4, %edx	 #, niters_vector_mult_vf.450_274
	addl	%edx, %ecx	 # niters_vector_mult_vf.450_274, tmp.451
	testb	$3, %al	 #, niters.448
	je	.L54	 #,
.L59:
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movl	%ecx, %eax	 # tmp.451, tmp364
	movl	$97, %r9d	 #, tmp365
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movslq	%ecx, %r10	 # tmp.451, _34
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	$89, %r8d	 #, tmp373
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	cltd
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovss	.LC11(%rip), %xmm2	 #, tmp369
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovss	.LC16(%rip), %xmm1	 #, tmp377
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1131: 	return *(this->_M_impl._M_start + __n);
	leaq	0(,%r10,4), %r11	 #, _32
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	idivl	%r9d	 # tmp365
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	%ecx, %eax	 # tmp.451, tmp372
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	addl	$1, %edx	 #, _6
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _6, tmp556, tmp557
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	cltd
	idivl	%r8d	 # tmp373
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulss	%xmm2, %xmm0, %xmm0	 # tmp369, _7, _8
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovss	%xmm0, (%rsi,%r10,4)	 # _8, *_9
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	addl	$3, %edx	 #, _12
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _12, tmp556, tmp558
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulss	%xmm1, %xmm0, %xmm0	 # tmp377, _60, _62
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovss	%xmm0, (%rdi,%r10,4)	 # _62, *_184
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	leal	1(%rcx), %r10d	 #, i
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	cmpl	%r10d, %ebx	 # i, iftmp.18_27
	jle	.L54	 #,
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movl	%r10d, %eax	 # i, tmp384
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	addl	$2, %ecx	 #, i
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	cltd
	idivl	%r9d	 # tmp365
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	%r10d, %eax	 # i, i
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	addl	$1, %edx	 #, _191
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _191, tmp556, tmp559
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	cltd
	idivl	%r8d	 # tmp373
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulss	%xmm2, %xmm0, %xmm0	 # tmp369, _192, _194
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovss	%xmm0, 4(%rsi,%r11)	 # _194, *_197
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	addl	$3, %edx	 #, _202
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _202, tmp556, tmp560
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulss	%xmm1, %xmm0, %xmm0	 # tmp377, _267, _281
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovss	%xmm0, 4(%rdi,%r11)	 # _281, *_284
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	cmpl	%ecx, %ebx	 # i, iftmp.18_27
	jle	.L54	 #,
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movl	%ecx, %eax	 # i, tmp408
	cltd
	idivl	%r9d	 # tmp365
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	%ecx, %eax	 # i, i
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	addl	$1, %edx	 #, _252
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _252, tmp556, tmp561
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	cltd
	idivl	%r8d	 # tmp373
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulss	%xmm2, %xmm0, %xmm0	 # tmp369, _253, _254
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovss	%xmm0, 8(%rsi,%r11)	 # _254, *_257
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	addl	$3, %edx	 #, _260
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtsi2ssl	%edx, %xmm10, %xmm10	 # _260, tmp556, tmp562
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulss	%xmm1, %xmm10, %xmm10	 # tmp377, _261, _262
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovss	%xmm10, 8(%rdi,%r11)	 # _262, *_263
.L54:
 # analysis\manual_vs_autovec.cc:86:     const double scalar_ns = BenchmarkKernel(ip_distance_scalar_novec, a, b, d, repeat);
	movl	%ebp, 32(%rsp)	 # iftmp.19_17,
	movl	%ebx, %r9d	 # iftmp.18_27,
	movq	%r13, %r8	 # tmp536,
	movq	%r12, %rdx	 # tmp534,
	leaq	_ZN12_GLOBAL__N_124ip_distance_scalar_novecEPKfS1_i(%rip), %rcx	 #, tmp469
.LEHB2:
	call	_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii	 #
 # analysis\manual_vs_autovec.cc:87:     const double auto_ns = BenchmarkKernel(ip_distance_auto, a, b, d, repeat);
	movl	%ebp, 32(%rsp)	 # iftmp.19_17,
	movl	%ebx, %r9d	 # iftmp.18_27,
	movq	%r13, %r8	 # tmp536,
	movq	%r12, %rdx	 # tmp534,
	leaq	_ZN12_GLOBAL__N_116ip_distance_autoEPKfS1_i(%rip), %rcx	 #, tmp472
 # analysis\manual_vs_autovec.cc:86:     const double scalar_ns = BenchmarkKernel(ip_distance_scalar_novec, a, b, d, repeat);
	vmovapd	%xmm0, %xmm8	 # tmp541, _37
 # analysis\manual_vs_autovec.cc:87:     const double auto_ns = BenchmarkKernel(ip_distance_auto, a, b, d, repeat);
	call	_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii	 #
 # analysis\manual_vs_autovec.cc:88:     const double manual_ns = BenchmarkKernel(ip_distance_manual, a, b, d, repeat);
	movl	%ebp, 32(%rsp)	 # iftmp.19_17,
	movl	%ebx, %r9d	 # iftmp.18_27,
	movq	%r13, %r8	 # tmp536,
	movq	%r12, %rdx	 # tmp534,
	leaq	_ZN12_GLOBAL__N_118ip_distance_manualEPKfS1_i(%rip), %rcx	 #, tmp475
 # analysis\manual_vs_autovec.cc:87:     const double auto_ns = BenchmarkKernel(ip_distance_auto, a, b, d, repeat);
	vmovapd	%xmm0, %xmm7	 # tmp542, _39
 # analysis\manual_vs_autovec.cc:88:     const double manual_ns = BenchmarkKernel(ip_distance_manual, a, b, d, repeat);
	call	_ZN12_GLOBAL__N_115BenchmarkKernelIPFfPKfS2_iEEEdT_RKSt6vectorIfSaIfEESA_ii	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movq	.refptr._ZSt4cout(%rip), %r12	 #, tmp532
	movl	$5, %r8d	 #,
	leaq	.LC26(%rip), %rdx	 #, tmp476
 # analysis\manual_vs_autovec.cc:88:     const double manual_ns = BenchmarkKernel(ip_distance_manual, a, b, d, repeat);
	vmovapd	%xmm0, %xmm6	 # tmp543, _41
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
.LEHE2:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:194: 	: allocator_type(__a), _M_p(__dat) { }
	leaq	144(%rsp), %rdx	 #, tmp479
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:4082:       return __ostream_insert(__os, __str.data(), __str.size());
	movq	%r12, %rcx	 # tmp532,
	movl	$4, %r8d	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/char_traits.h:427: 	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
	movl	$846755425, 144(%rsp)	 #, MEM <char[1:4]> [(void *)&D.105729 + 16B]
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:194: 	: allocator_type(__a), _M_p(__dat) { }
	movq	%rdx, 128(%rsp)	 # tmp479, MEM[(struct _Alloc_hider *)&D.105729]._M_p
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:223:       { _M_string_length = __length; }
	movq	$4, 136(%rsp)	 #, D.105729._M_string_length
 # C:/msys64/mingw64/include/c++/14.2.0/bits/char_traits.h:350: 	__c1 = __c2;
	movb	$0, 148(%rsp)	 #, MEM[(char_type &)&D.105729 + 20]
.LEHB3:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:4082:       return __ostream_insert(__os, __str.data(), __str.size());
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # analysis\manual_vs_autovec.cc:90:     std::cout << "arch=" << ArchLabel() << "\n";
	leaq	.LC27(%rip), %r13	 #, tmp531
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:4082:       return __ostream_insert(__os, __str.data(), __str.size());
	movq	%rax, %rcx	 # tmp544, _68
 # analysis\manual_vs_autovec.cc:90:     std::cout << "arch=" << ArchLabel() << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
.LEHE3:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:809:       { _M_dispose(); }
	leaq	128(%rsp), %rcx	 #, tmp486
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$2, %r8d	 #,
	leaq	.LC28(%rip), %rdx	 #, tmp487
	movq	%r12, %rcx	 # tmp532,
.LEHB4:
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # analysis\manual_vs_autovec.cc:91:     std::cout << "d=" << d << " repeat=" << repeat << "\n";
	movl	%ebx, %edx	 # iftmp.18_27,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSolsEi	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$8, %r8d	 #,
	leaq	.LC29(%rip), %rdx	 #, tmp490
	movq	%rax, %rcx	 # _45,
 # analysis\manual_vs_autovec.cc:91:     std::cout << "d=" << d << " repeat=" << repeat << "\n";
	movq	%rax, %rbx	 # tmp545, _45
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # analysis\manual_vs_autovec.cc:91:     std::cout << "d=" << d << " repeat=" << repeat << "\n";
	movl	%ebp, %edx	 # iftmp.19_17,
	movq	%rbx, %rcx	 # _45,
	call	_ZNSolsEi	 #
	movq	%rax, %rcx	 # tmp546, _47
 # analysis\manual_vs_autovec.cc:91:     std::cout << "d=" << d << " repeat=" << repeat << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$16, %r8d	 #,
	leaq	.LC30(%rip), %rdx	 #, tmp492
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vmovapd	%xmm8, %xmm1	 # _37,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp547, _69
 # analysis\manual_vs_autovec.cc:92:     std::cout << "scalar_novec_ns=" << scalar_ns << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$11, %r8d	 #,
	leaq	.LC31(%rip), %rdx	 #, tmp496
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vmovapd	%xmm7, %xmm1	 # _39,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp548, _70
 # analysis\manual_vs_autovec.cc:93:     std::cout << "autovec_ns=" << auto_ns << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$15, %r8d	 #,
	leaq	.LC32(%rip), %rdx	 #, tmp500
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vmovapd	%xmm6, %xmm1	 # _41,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp549, _71
 # analysis\manual_vs_autovec.cc:94:     std::cout << "manual_simd_ns=" << manual_ns << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$26, %r8d	 #,
	leaq	.LC33(%rip), %rdx	 #, tmp504
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vdivsd	%xmm7, %xmm8, %xmm1	 # _39, _37,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp550, _72
 # analysis\manual_vs_autovec.cc:95:     std::cout << "autovec_speedup_vs_scalar=" << (scalar_ns / auto_ns) << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$25, %r8d	 #,
	leaq	.LC34(%rip), %rdx	 #, tmp509
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vdivsd	%xmm6, %xmm8, %xmm1	 # _41, _37,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp551, _73
 # analysis\manual_vs_autovec.cc:96:     std::cout << "manual_speedup_vs_scalar=" << (scalar_ns / manual_ns) << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:673: 	__ostream_insert(__out, __s,
	movl	$26, %r8d	 #,
	leaq	.LC35(%rip), %rdx	 #, tmp514
	movq	%r12, %rcx	 # tmp532,
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x	 #
 # C:/msys64/mingw64/include/c++/14.2.0/ostream:229:       { return _M_insert(__f); }
	vdivsd	%xmm6, %xmm7, %xmm1	 # _41, _39,
	movq	%r12, %rcx	 # tmp532,
	call	_ZNSo9_M_insertIdEERSoT_	 #
	movq	%rax, %rcx	 # tmp552, _74
 # analysis\manual_vs_autovec.cc:97:     std::cout << "manual_speedup_vs_autovec=" << (auto_ns / manual_ns) << "\n";
	movq	%r13, %rdx	 # tmp531,
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc.isra.0	 #
.LEHE4:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:388: 	if (__p)
	testq	%rdi, %rdi	 # b$D105400$_M_impl$D104740$_M_start
	je	.L63	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	%r15, %rdx	 # b$_M_impl$D104740$_M_end_of_storage, b$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	movq	%rdi, %rcx	 # b$D105400$_M_impl$D104740$_M_start,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	subq	%rdi, %rdx	 # b$D105400$_M_impl$D104740$_M_start, b$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	call	_ZdlPvy	 #
.L63:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:388: 	if (__p)
	testq	%rsi, %rsi	 # a$D105400$_M_impl$D104740$_M_start
	je	.L83	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	56(%rsp), %rdx	 # %sfp, a$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	movq	%rsi, %rcx	 # a$D105400$_M_impl$D104740$_M_start,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	subq	%rsi, %rdx	 # a$D105400$_M_impl$D104740$_M_start, a$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	call	_ZdlPvy	 #
	nop	
.L83:
 # analysis\manual_vs_autovec.cc:99: }
	vmovups	160(%rsp), %xmm6	 #,
	xorl	%eax, %eax	 #
	vmovups	176(%rsp), %xmm7	 #,
	vmovups	192(%rsp), %xmm8	 #,
	vmovups	208(%rsp), %xmm9	 #,
	vmovups	224(%rsp), %xmm10	 #,
	vmovups	240(%rsp), %xmm11	 #,
	vmovups	256(%rsp), %xmm12	 #,
	vmovups	272(%rsp), %xmm13	 #,
	addq	$296, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
	popq	%rdi	 #
	popq	%rbp	 #
	popq	%r12	 #
	popq	%r13	 #
	popq	%r14	 #
	popq	%r15	 #
	ret	
.L99:
 # analysis\manual_vs_autovec.cc:76:     const int d = (argc >= 2) ? std::atoi(argv[1]) : 96;
	movq	8(%rdi), %rcx	 # MEM[(char * *)argv_25(D) + 8B], MEM[(char * *)argv_25(D) + 8B]
	call	atoi	 #
	movl	%eax, %ebx	 # tmp539, iftmp.18_27
 # analysis\manual_vs_autovec.cc:77:     const int repeat = (argc >= 3) ? std::atoi(argv[2]) : 2000000;
	cmpl	$2, %esi	 #, argc
	je	.L53	 #,
 # analysis\manual_vs_autovec.cc:77:     const int repeat = (argc >= 3) ? std::atoi(argv[2]) : 2000000;
	movq	16(%rdi), %rcx	 # MEM[(char * *)argv_25(D) + 16B], MEM[(char * *)argv_25(D) + 16B]
	call	atoi	 #
	movl	%eax, %ebp	 # tmp540, iftmp.19_17
	jmp	.L53	 #
.L100:
	vzeroupper
	jmp	.L59	 #
.L73:
	vmovss	.LC11(%rip), %xmm2	 #, tmp533
	vmovss	.LC16(%rip), %xmm1	 #, tmp535
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	xorl	%eax, %eax	 # ivtmp.476
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	$3088515809, %ecx	 #, tmp450
	.p2align 4
	.p2align 3
.L61:
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	movslq	%eax, %rdx	 # ivtmp.476, i
	movl	%eax, %r8d	 # ivtmp.476, tmp440
	imulq	$354224107, %rdx, %rdx	 #, i, tmp437
	sarl	$31, %r8d	 #, tmp440
	sarq	$35, %rdx	 #, tmp439
	subl	%r8d, %edx	 # tmp440, tmp435
	movl	%eax, %r8d	 # ivtmp.476, _167
	imull	$97, %edx, %edx	 #, tmp435, tmp441
	subl	%edx, %r8d	 # tmp441, _167
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	leal	1(%r8), %edx	 #, _168
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	%eax, %r8d	 # ivtmp.476, _175
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _168, tmp556, tmp563
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	movl	%eax, %edx	 # ivtmp.476, i
	imulq	%rcx, %rdx	 # tmp450, tmp449
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmulss	%xmm2, %xmm0, %xmm0	 # tmp533, _169, _170
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	shrq	$38, %rdx	 #, tmp447
	imull	$89, %edx, %edx	 #, tmp447, tmp452
	subl	%edx, %r8d	 # tmp452, _175
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	leal	3(%r8), %edx	 #, _176
 # analysis\manual_vs_autovec.cc:82:         a[static_cast<size_t>(i)] = 0.001f * static_cast<float>((i % 97) + 1);
	vmovss	%xmm0, (%rsi,%rax,4)	 # _170, MEM[(value_type &)a$D105400$_M_impl$D104740$_M_start_67 + ivtmp.476_341 * 4]
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vcvtsi2ssl	%edx, %xmm10, %xmm0	 # _176, tmp556, tmp564
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmulss	%xmm1, %xmm0, %xmm0	 # tmp535, _177, _178
 # analysis\manual_vs_autovec.cc:83:         b[static_cast<size_t>(i)] = 0.002f * static_cast<float>((i % 89) + 3);
	vmovss	%xmm0, (%rdi,%rax,4)	 # _178, MEM[(value_type &)b$D105400$_M_impl$D104740$_M_start_138 + ivtmp.476_341 * 4]
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	addq	$1, %rax	 #, ivtmp.476
	cmpq	%rax, %r14	 # ivtmp.476, _3
	jne	.L61	 #,
	jmp	.L54	 #
.L97:
	vzeroupper
	jmp	.L54	 #
.L74:
	xorl	%edx, %edx	 #
 # analysis\manual_vs_autovec.cc:81:     for (int i = 0; i < d; ++i) {
	xorl	%ecx, %ecx	 # tmp.451
	jmp	.L56	 #
.L75:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	%rax, %rbx	 # tmp555, tmp527
	vzeroupper
.L68:
	movq	56(%rsp), %rdx	 # %sfp, a$_M_impl$D104740$_M_end_of_storage
	subq	%rsi, %rdx	 # a$D105400$_M_impl$D104740$_M_start, a$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:388: 	if (__p)
	testq	%rsi, %rsi	 # a$D105400$_M_impl$D104740$_M_start
	je	.L69	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	movq	%rsi, %rcx	 # a$D105400$_M_impl$D104740$_M_start,
	call	_ZdlPvy	 #
.L69:
	movq	%rbx, %rcx	 # tmp527,
.LEHB5:
	call	_Unwind_Resume	 #
.LEHE5:
.L76:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	%rax, %rbx	 # tmp554, tmp523
	vzeroupper
.L66:
	movq	%r15, %rdx	 # b$_M_impl$D104740$_M_end_of_storage, b$_M_impl$D104740$_M_end_of_storage
	subq	%rdi, %rdx	 # b$D105400$_M_impl$D104740$_M_start, b$_M_impl$D104740$_M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:388: 	if (__p)
	testq	%rdi, %rdi	 # b$D105400$_M_impl$D104740$_M_start
	je	.L68	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	movq	%rdi, %rcx	 # b$D105400$_M_impl$D104740$_M_start,
	call	_ZdlPvy	 #
 # C:/msys64/mingw64/include/c++/14.2.0/bits/alloc_traits.h:513:       { __a.deallocate(__p, __n); }
	jmp	.L68	 #
.L77:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/basic_string.h:809:       { _M_dispose(); }
	leaq	128(%rsp), %rcx	 #, tmp522
	movq	%rax, %rbx	 # tmp553, tmp524
	vzeroupper
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv	 #
	jmp	.L66	 #
	.seh_handler	__gxx_personality_seh0, @unwind, @except
	.seh_handlerdata
.LLSDA9655:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE9655-.LLSDACSB9655
.LLSDACSB9655:
	.uleb128 .LEHB0-.LFB9655
	.uleb128 .LEHE0-.LEHB0
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB1-.LFB9655
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L75-.LFB9655
	.uleb128 0
	.uleb128 .LEHB2-.LFB9655
	.uleb128 .LEHE2-.LEHB2
	.uleb128 .L76-.LFB9655
	.uleb128 0
	.uleb128 .LEHB3-.LFB9655
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L77-.LFB9655
	.uleb128 0
	.uleb128 .LEHB4-.LFB9655
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L76-.LFB9655
	.uleb128 0
	.uleb128 .LEHB5-.LFB9655
	.uleb128 .LEHE5-.LEHB5
	.uleb128 0
	.uleb128 0
.LLSDACSE9655:
	.section	.text.startup,"x"
	.seh_endproc
	.section .rdata,"dr"
.LC42:
	.ascii "vector::_M_realloc_append\0"
	.section	.text$_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_,"x"
	.linkonce discard
	.align 2
	.p2align 4
	.globl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_
	.def	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_;	.scl	2;	.type	32;	.endef
	.seh_proc	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_
_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_:
.LFB10347:
	pushq	%r14	 #
	.seh_pushreg	%r14
	pushq	%r13	 #
	.seh_pushreg	%r13
	pushq	%r12	 #
	.seh_pushreg	%r12
	pushq	%rbp	 #
	.seh_pushreg	%rbp
	pushq	%rdi	 #
	.seh_pushreg	%rdi
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$32, %rsp	 #,
	.seh_stackalloc	32
	.seh_endprologue
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1908: 	if (max_size() - size() < __n)
	movabsq	$1152921504606846975, %rax	 #, tmp130
	movq	8(%rcx), %rbx	 # MEM[(struct pair * *)this_8(D) + 8B], _34
	movq	(%rcx), %rbp	 # MEM[(struct pair * *)this_8(D)], _33
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:993:       { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
	movq	%rbx, %r14	 # _34, _37
	subq	%rbp, %r14	 # _33, _37
	movq	%r14, %rsi	 # _37, _38
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:581:       vector<_Tp, _Alloc>::
	movq	%rcx, %rdi	 # tmp144, this
	movq	%rdx, %r13	 # tmp145, __args#0
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:993:       { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
	sarq	$3, %rsi	 #, _38
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1908: 	if (max_size() - size() < __n)
	cmpq	%rax, %rsi	 # tmp130, _38
	je	.L115	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_algobase.h:262:       if (__a < __b)
	testq	%rsi, %rsi	 # _38
	movl	$1, %eax	 #, tmp150
	cmovne	%rsi, %rax	 # _38,, _42
	addq	%rax, %rsi	 # _42, tmp133
	jc	.L104	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1912: 	return (__len < size() || __len > max_size()) ? max_size() : __len;
	movabsq	$1152921504606846975, %rax	 #, tmp149
	cmpq	%rax, %rsi	 # tmp149, tmp133
	cmova	%rax, %rsi	 # tmp133,, tmp149, _44
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:151: 	return static_cast<_Tp*>(_GLIBCXX_OPERATOR_NEW(__n * sizeof(_Tp)));
	salq	$3, %rsi	 #, _20
.L105:
	movq	%rsi, %rcx	 # _20,
	call	_Znwy	 #
	movq	%rax, %r12	 # tmp146, _50
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	movq	0(%r13), %rax	 # *__args#0_14(D), *__args#0_14(D)
	movq	%rax, (%r12,%r14)	 # *__args#0_14(D), *_2
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1102:       for (; __first != __last; ++__first, (void)++__cur)
	cmpq	%rbx, %rbp	 # _34, _33
	je	.L110	 #,
	subq	%rbp, %rbx	 # _33, _36
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1101:       _ForwardIterator __cur = __result;
	movq	%r12, %rax	 # _50, __cur
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1102:       for (; __first != __last; ++__first, (void)++__cur)
	movq	%rbp, %rdx	 # _33, __first
	leaq	(%r12,%rbx), %r8	 #, __cur
	.p2align 5
	.p2align 4
	.p2align 3
.L107:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	movq	(%rdx), %rcx	 # MEM[(struct pair &)__first_40], MEM[(struct pair &)__first_40]
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1102:       for (; __first != __last; ++__first, (void)++__cur)
	addq	$8, %rax	 #, __cur
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1102:       for (; __first != __last; ++__first, (void)++__cur)
	addq	$8, %rdx	 #, __first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	movq	%rcx, -8(%rax)	 # MEM[(struct pair &)__first_40], MEM[(struct pair *)__cur_15]
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1102:       for (; __first != __last; ++__first, (void)++__cur)
	cmpq	%r8, %rax	 # __cur, __cur
	jne	.L107	 #,
.L106:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:649: 	    ++__new_finish;
	leaq	8(%rax), %rbx	 #, __new_finish
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:614: 	  if (_M_storage)
	testq	%rbp, %rbp	 # _33
	je	.L108	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:687: 	__guard._M_len = this->_M_impl._M_end_of_storage - __old_start;
	movq	16(%rdi), %rdx	 # this_8(D)->D.102498._M_impl.D.101799._M_end_of_storage, _4
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	movq	%rbp, %rcx	 # _33,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:687: 	__guard._M_len = this->_M_impl._M_end_of_storage - __old_start;
	subq	%rbp, %rdx	 # _33, _4
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	call	_ZdlPvy	 #
.L108:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:692:       this->_M_impl._M_start = __new_start;
	movq	%r12, (%rdi)	 # _50, this_8(D)->D.102498._M_impl.D.101799._M_start
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:694:       this->_M_impl._M_end_of_storage = __new_start + __len;
	addq	%rsi, %r12	 # _20, tmp140
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:693:       this->_M_impl._M_finish = __new_finish;
	movq	%rbx, 8(%rdi)	 # __new_finish, this_8(D)->D.102498._M_impl.D.101799._M_finish
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:694:       this->_M_impl._M_end_of_storage = __new_start + __len;
	movq	%r12, 16(%rdi)	 # tmp140, this_8(D)->D.102498._M_impl.D.101799._M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:695:     }
	addq	$32, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
	popq	%rdi	 #
	popq	%rbp	 #
	popq	%r12	 #
	popq	%r13	 #
	popq	%r14	 #
	ret	
	.p2align 4,,10
	.p2align 3
.L110:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_uninitialized.h:1101:       _ForwardIterator __cur = __result;
	movq	%r12, %rax	 # _50, __cur
	jmp	.L106	 #
.L104:
	movabsq	$9223372036854775800, %rsi	 #, _20
	jmp	.L105	 #
.L115:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1909: 	  __throw_length_error(__N(__s));
	leaq	.LC42(%rip), %rcx	 #, tmp131
	call	_ZSt20__throw_length_errorPKc	 #
	nop	
	.seh_endproc
	.text
	.p2align 4
	.globl	_Z11flat_searchPfS_yyy
	.def	_Z11flat_searchPfS_yyy;	.scl	2;	.type	32;	.endef
	.seh_proc	_Z11flat_searchPfS_yyy
_Z11flat_searchPfS_yyy:
.LFB9625:
	pushq	%r15	 #
	.seh_pushreg	%r15
	pushq	%r14	 #
	.seh_pushreg	%r14
	pushq	%r13	 #
	.seh_pushreg	%r13
	pushq	%r12	 #
	.seh_pushreg	%r12
	pushq	%rbp	 #
	.seh_pushreg	%rbp
	pushq	%rdi	 #
	.seh_pushreg	%rdi
	pushq	%rsi	 #
	.seh_pushreg	%rsi
	pushq	%rbx	 #
	.seh_pushreg	%rbx
	subq	$120, %rsp	 #,
	.seh_stackalloc	120
	vmovups	%xmm6, 96(%rsp)	 #,
	.seh_savexmm	%xmm6, 96
	.seh_endprologue
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	vpxor	%xmm0, %xmm0, %xmm0	 # tmp331
 # analysis\../flat_scan_avx2.h:72: flat_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k) {
	movq	%rcx, %r14	 # tmp454, <retval>
	movq	%rdx, %r15	 # tmp455, base
	movq	%r8, %rsi	 # tmp456, query
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	vmovdqu	%xmm0, (%rcx)	 # tmp331, MEM <vector(2) long long unsigned int> [(struct pair * *)q_14(D)]
 # analysis\../flat_scan_avx2.h:72: flat_search(float* base, float* query, size_t base_number, size_t vecdim, size_t k) {
	movq	%r9, 216(%rsp)	 # tmp457, base_number
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:99: 	: _M_start(), _M_finish(), _M_end_of_storage()
	movq	$0, 16(%rcx)	 #, MEM[(struct _Vector_impl_data *)q_14(D)]._M_end_of_storage
 # analysis\../flat_scan_avx2.h:75:     for (size_t i = 0; i < base_number; ++i) {
	testq	%r9, %r9	 #
	je	.L116	 #,
 # analysis\../flat_scan_avx2.h:76:         float dis = ann_avx2::ip_distance_avx2(base + i * vecdim, query,
	movl	224(%rsp), %ebx	 # vecdim, _1
	xorl	%ebp, %ebp	 # ivtmp.566
	xorl	%ecx, %ecx	 # prephitmp_483
 # analysis\../flat_scan_avx2.h:75:     for (size_t i = 0; i < base_number; ++i) {
	xorl	%edi, %edi	 # i
	vmovss	.LC1(%rip), %xmm6	 #, tmp450
	movl	%ebx, %eax	 # _507, tmp527
	movl	%ebx, %r12d	 # _1, _507
	subl	$32, %eax	 #, _504
	movl	%eax, %edx	 # _504, _503
	movl	%eax, 36(%rsp)	 # _504, %sfp
 # analysis\../flat_scan_avx2.h:76:         float dis = ann_avx2::ip_distance_avx2(base + i * vecdim, query,
	xorl	%eax, %eax	 # prephitmp_485
	shrl	$5, %edx	 #, _503
	addl	$1, %edx	 #,
	salq	$7, %rdx	 #, _623
	movq	%rdx, 40(%rsp)	 # _623, %sfp
	.p2align 4
	.p2align 3
.L165:
	leaq	(%r15,%rbp,4), %rdx	 #, ivtmp.558
 # analysis\../flat_scan_avx2.h:76:         float dis = ann_avx2::ip_distance_avx2(base + i * vecdim, query,
	movq	%rdx, %r8	 # ivtmp.558, _4
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	cmpl	$31, %ebx	 #, _1
	jle	.L169	 #,
	movq	40(%rsp), %r11	 # %sfp, _689
 # analysis\../flat_scan_avx2.h:30:     __m256 sum3 = _mm256_setzero_ps();
	vxorps	%xmm3, %xmm3, %xmm3	 # sum3
	movq	%rsi, %r9	 # query, ivtmp.559
 # analysis\../flat_scan_avx2.h:29:     __m256 sum2 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm1	 #, sum2
 # analysis\../flat_scan_avx2.h:28:     __m256 sum1 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm2	 # tmp21, sum1
 # analysis\../flat_scan_avx2.h:27:     __m256 sum0 = _mm256_setzero_ps();
	vmovaps	%ymm3, %ymm0	 # tmp21, sum0
	leaq	(%r11,%rdx), %r10	 #, _319
	.p2align 6
	.p2align 4
	.p2align 3
.L119:
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	(%rdx), %ymm4	 # MEM[(__m256_u * {ref-all})_515], tmp531
	vmovups	32(%rdx), %ymm5	 # MEM[(__m256_u * {ref-all})_515 + 32B], tmp532
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	subq	$-128, %rdx	 #, ivtmp.558
	subq	$-128, %r9	 #, ivtmp.559
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vfmadd231ps	-128(%r9), %ymm4, %ymm0	 # MEM[(__m256_u * {ref-all})_511], tmp531, sum0
	vfmadd231ps	-96(%r9), %ymm5, %ymm2	 # MEM[(__m256_u * {ref-all})_511 + 32B], tmp532, sum1
	vmovups	-64(%rdx), %ymm4	 # MEM[(__m256_u * {ref-all})_515 + 64B], tmp533
	vmovups	-32(%rdx), %ymm5	 # MEM[(__m256_u * {ref-all})_515 + 96B], tmp534
	vfmadd231ps	-64(%r9), %ymm4, %ymm1	 # MEM[(__m256_u * {ref-all})_511 + 64B], tmp533, sum2
	vfmadd231ps	-32(%r9), %ymm5, %ymm3	 # MEM[(__m256_u * {ref-all})_511 + 96B], tmp534, sum3
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	cmpq	%r10, %rdx	 # _319, ivtmp.558
	jne	.L119	 #,
	movl	36(%rsp), %r9d	 # %sfp, _561
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:149:   return (__m256) ((__v8sf)__A + (__v8sf)__B);
	vaddps	%ymm3, %ymm1, %ymm1	 # sum3, sum2, _526
	andl	$-32, %r9d	 #, _561
	leal	32(%r9), %edx	 #, tmp.540
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	addl	$39, %r9d	 #, _528
.L118:
	cmpl	%r9d, %ebx	 # _528, _1
	jle	.L120	 #,
 # analysis\../flat_scan_avx2.h:52:         __m256 vx = _mm256_loadu_ps(x + i);
	movslq	%edx, %r9	 # tmp.540, _609
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	(%r8,%r9,4), %ymm3	 # MEM[(__m256_u * {ref-all})_693], tmp536
 # analysis\../flat_scan_avx2.h:52:         __m256 vx = _mm256_loadu_ps(x + i);
	leaq	0(,%r9,4), %r10	 #, _589
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vfmadd231ps	(%rsi,%r9,4), %ymm3, %ymm0	 # MEM[(__m256_u * {ref-all})_557], tmp536, sum0
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	leal	15(%rdx), %r9d	 #, _554
	cmpl	%r9d, %ebx	 # _554, _1
	jle	.L121	 #,
	leal	23(%rdx), %r9d	 #, _216
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	32(%r8,%r10), %ymm3	 # MEM[(__m256_u * {ref-all})_607], tmp537
	vfmadd231ps	32(%rsi,%r10), %ymm3, %ymm0	 # MEM[(__m256_u * {ref-all})_518], tmp537, sum0
 # analysis\../flat_scan_avx2.h:51:     for (; i + 8 <= d; i += 8) {
	cmpl	%r9d, %ebx	 # _216, _1
	jle	.L121	 #,
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/fmaintrin.h:65:   return (__m256)__builtin_ia32_vfmaddps256 ((__v8sf)__A, (__v8sf)__B,
	vmovups	64(%r8,%r10), %ymm3	 # MEM[(__m256_u * {ref-all})_85], tmp538
	vfmadd231ps	64(%rsi,%r10), %ymm3, %ymm0	 # MEM[(__m256_u * {ref-all})_87], tmp538, sum0
.L121:
	leal	-8(%r12), %r9d	 #, _672
	leal	7(%rdx), %r10d	 #, _578
	subl	%edx, %r9d	 # tmp.540, _576
	andl	$-8, %r9d	 #, _584
	cmpl	%r10d, %ebx	 # _578, _1
	movl	$0, %r10d	 #, tmp365
	cmovle	%r10d, %r9d	 # _584,, tmp365, _584
	leal	8(%rdx,%r9), %edx	 #, tmp.540
.L120:
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:149:   return (__m256) ((__v8sf)__A + (__v8sf)__B);
	vaddps	%ymm2, %ymm0, %ymm0	 # sum1, sum0, _94
	vaddps	%ymm1, %ymm0, %ymm0	 # _526, _94, _95
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:272:   return (__m256) __builtin_ia32_haddps256 ((__v8sf)__X, (__v8sf)__Y);
	vhaddps	%ymm0, %ymm0, %ymm0	 # _95, _95, tmp368
	vhaddps	%ymm0, %ymm0, %ymm0	 # tmp368, tmp368, tmp369
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:1472:   return (__m128) __builtin_ia32_ps_ps256 ((__v8sf)__A);
	vmovaps	%xmm0, %xmm1	 # tmp369, tmp370
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/avxintrin.h:526:   return (__m128) __builtin_ia32_vextractf128_ps256 ((__v8sf)__X, __N);
	vextractf128	$0x1, %ymm0, %xmm0	 # tmp369, tmp372
 # C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/xmmintrin.h:136:   return (__m128) __builtin_ia32_addss ((__v4sf)__A, (__v4sf)__B);
	vaddss	%xmm0, %xmm1, %xmm0	 # tmp372, tmp370, tmp374
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%edx, %ebx	 # tmp.540, _1
	jle	.L122	 #,
	movl	%r12d, %r9d	 # _507, niters.537
	subl	%edx, %r9d	 # tmp.540, niters.537
	leal	-1(%r9), %r10d	 #, _479
	cmpl	$2, %r10d	 #, _479
	jbe	.L123	 #,
	movslq	%edx, %r10	 # tmp.540, _471
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	leaq	(%r10,%rbp), %r11	 #, tmp376
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovups	(%rsi,%r10,4), %xmm1	 # MEM <const vector(4) float> [(const float *)vectp.545_465], vect__108.546_460
	movl	%r9d, %r10d	 # niters.537, niters_vector_mult_vf.539_475
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmulps	(%r15,%r11,4), %xmm1, %xmm1	 # MEM <const vector(4) float> [(const float *)vectp.542_472], vect__108.546_460, vect__109.547
	andl	$-4, %r10d	 #, niters_vector_mult_vf.539_475
	addl	%r10d, %edx	 # niters_vector_mult_vf.539_475, tmp.540
	andl	$3, %r9d	 #, niters.537
	vaddss	%xmm1, %xmm0, %xmm0	 # stmp_dot_111.548, dot, stmp_dot_111.548
	vshufps	$85, %xmm1, %xmm1, %xmm2	 #, vect__109.547, vect__109.547, stmp_dot_111.548
	vaddss	%xmm0, %xmm2, %xmm2	 # stmp_dot_111.548, stmp_dot_111.548, stmp_dot_111.548
	vunpckhps	%xmm1, %xmm1, %xmm0	 # vect__109.547, vect__109.547, stmp_dot_111.548
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vshufps	$255, %xmm1, %xmm1, %xmm1	 #, vect__109.547, vect__109.547, stmp_dot_111.548_452
	vaddss	%xmm2, %xmm0, %xmm0	 # stmp_dot_111.548, stmp_dot_111.548, stmp_dot_111.548_453
	vaddss	%xmm1, %xmm0, %xmm0	 # stmp_dot_111.548_452, stmp_dot_111.548_453, dot
	je	.L122	 #,
.L123:
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	movslq	%edx, %r9	 # tmp.540, _104
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	(%r8,%r9,4), %xmm3	 # *_106, tmp541
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	leaq	0(,%r9,4), %r10	 #, _105
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vfmadd231ss	(%rsi,%r9,4), %xmm3, %xmm0	 # *_108, tmp541, dot
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	leal	1(%rdx), %r9d	 #, i_548
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%r9d, %ebx	 # i_548, _1
	jle	.L122	 #,
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	addl	$2, %edx	 #, i_206
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	4(%r8,%r10), %xmm3	 # *_200, tmp542
	vfmadd231ss	4(%rsi,%r10), %xmm3, %xmm0	 # *_202, tmp542, dot
 # analysis\../flat_scan_avx2.h:61:     for (; i < d; ++i) {
	cmpl	%edx, %ebx	 # i_206, _1
	jle	.L122	 #,
 # analysis\../flat_scan_avx2.h:62:         dot += x[i] * y[i];
	vmovss	8(%rsi,%r10), %xmm2	 # *_493, tmp543
	vfmadd231ss	8(%r8,%r10), %xmm2, %xmm0	 # *_495, tmp543, dot
.L122:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:993:       { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
	movq	%rcx, %rdx	 # prephitmp_483, _19
 # analysis\../flat_scan_avx2.h:65:     return 1.0f - dot;
	vsubss	%xmm0, %xmm6, %xmm0	 # dot, tmp450, _113
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:993:       { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
	subq	%rax, %rdx	 # prephitmp_485, _19
	sarq	$3, %rdx	 #, _31
 # analysis\../flat_scan_avx2.h:79:         if (q.size() < k) {
	cmpq	232(%rsp), %rdx	 # k, _31
	jb	.L213	 #,
 # analysis\../flat_scan_avx2.h:81:         } else if (dis < q.top().first) {
	vmovss	(%rax), %xmm1	 # MEM[(const struct value_type &)prephitmp_485].first, MEM[(const struct value_type &)prephitmp_485].first
	vcomiss	%xmm0, %xmm1	 # _113, MEM[(const struct value_type &)prephitmp_485].first
	ja	.L214	 #,
.L135:
 # analysis\../flat_scan_avx2.h:75:     for (size_t i = 0; i < base_number; ++i) {
	addq	$1, %rdi	 #, i
 # analysis\../flat_scan_avx2.h:75:     for (size_t i = 0; i < base_number; ++i) {
	addq	224(%rsp), %rbp	 # vecdim, ivtmp.566
	cmpq	%rdi, 216(%rsp)	 # i, base_number
	jne	.L165	 #,
	vzeroupper
.L116:
 # analysis\../flat_scan_avx2.h:88: }
	vmovups	96(%rsp), %xmm6	 #,
	movq	%r14, %rax	 # <retval>,
	addq	$120, %rsp	 #,
	popq	%rbx	 #
	popq	%rsi	 #
	popq	%rdi	 #
	popq	%rbp	 #
	popq	%r12	 #
	popq	%r13	 #
	popq	%r14	 #
	popq	%r15	 #
	ret	
	.p2align 4,,10
	.p2align 3
.L213:
	movl	%edi, %r10d	 # i, _480
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:114: 	if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
	cmpq	%rcx, 16(%r14)	 # prephitmp_483, MEM[(struct vector *)q_14(D)].D.102498._M_impl.D.101799._M_end_of_storage
	je	.L126	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	movl	%edi, 4(%rcx)	 # i, prephitmp_483->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:119: 	    ++this->_M_impl._M_finish;
	addq	$8, %rcx	 #, prephitmp_483
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	vmovss	%xmm0, -8(%rcx)	 # _113, prephitmp_483->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:119: 	    ++this->_M_impl._M_finish;
	movq	%rcx, 8(%r14)	 # prephitmp_483, MEM[(struct vector *)q_14(D)].D.102498._M_impl.D.101799._M_finish
.L127:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%rcx, %r9	 # prephitmp_483, _125
	subq	%rax, %r9	 # prephitmp_485, _125
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%r9, %r8	 # _125, _126
	sarq	$3, %r8	 #, _126
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:216:       std::__push_heap(__first, _DistanceType((__last - __first) - 1),
	leaq	-1(%r8), %r11	 #, __holeIndex
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	subq	$2, %r8	 #, _131
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	movq	%r8, %rdx	 # _131, tmp393
	shrq	$63, %rdx	 #, tmp393
	addq	%r8, %rdx	 # _131, tmp394
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	-8(%rax,%r9), %r8	 #, _683
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	sarq	%rdx	 # __parent
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%r11, %r11	 # __holeIndex
	jle	.L129	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r8	 #, _683
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r8), %xmm1	 # MEM[(const struct pair &)_137].first, _138
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm1, %xmm0	 # _138, _113
	jbe	.L196	 #,
.L215:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	4(%r8), %r13d	 # MEM[(const struct pair &)_137].second, pretmp_673
.L134:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r11,8), %r9	 #, _141
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	leaq	-1(%rdx), %r11	 #, _143
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r13d, 4(%r9)	 # pretmp_673, _141->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm1, (%r9)	 # _138, _141->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	movq	%r11, %r9	 # _143, tmp399
	shrq	$63, %r9	 #, tmp399
	addq	%r11, %r9	 # _143, tmp400
	movq	%rdx, %r11	 # __parent, __holeIndex
	sarq	%r9	 # __parent_144
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%rdx, %rdx	 # __holeIndex
	je	.L129	 #,
	movq	%r9, %rdx	 # __parent_144, __parent
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r8	 #, _683
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r8), %xmm1	 # MEM[(const struct pair &)_137].first, _138
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm1, %xmm0	 # _138, _113
	ja	.L215	 #,
.L196:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm0, %xmm1	 # _113, _138
	ja	.L209	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%r8), %r13d	 # MEM[(const struct pair &)_137].second, pretmp_673
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	cmpl	%r10d, %r13d	 # _480, pretmp_673
	jb	.L134	 #,
.L209:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r11,8), %r8	 #, _683
.L129:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r10d, 4(%r8)	 # _480, prephitmp_686->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%r8)	 # _113, prephitmp_686->first
	jmp	.L135	 #
	.p2align 4,,10
	.p2align 3
.L214:
	movl	%edi, %r11d	 # i, _323
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:114: 	if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
	cmpq	%rcx, 16(%r14)	 # prephitmp_483, MEM[(struct vector *)q_14(D)].D.102498._M_impl.D.101799._M_end_of_storage
	je	.L137	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:119: 	    ++this->_M_impl._M_finish;
	leaq	8(%rcx), %r10	 #, _154
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:191: 	{ ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
	movl	%edi, 4(%rcx)	 # i, prephitmp_483->second
	vmovss	%xmm0, (%rcx)	 # _113, prephitmp_483->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:119: 	    ++this->_M_impl._M_finish;
	movq	%r10, 8(%r14)	 # _154, MEM[(struct vector *)q_14(D)].D.102498._M_impl.D.101799._M_finish
.L138:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%r10, %r9	 # _154, _160
	subq	%rax, %r9	 # prephitmp_485, _160
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%r9, %r8	 # _160, _161
	sarq	$3, %r8	 #, _161
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:216:       std::__push_heap(__first, _DistanceType((__last - __first) - 1),
	leaq	-1(%r8), %r13	 #, __holeIndex
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	subq	$2, %r8	 #, _166
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	movq	%r8, %rdx	 # _166, tmp408
	shrq	$63, %rdx	 #, tmp408
	addq	%r8, %rdx	 # _166, tmp409
	sarq	%rdx	 # __parent
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%r13, %r13	 # __holeIndex
	jle	.L216	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r8	 #, _600
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r8), %xmm1	 # MEM[(const struct pair &)_172].first, _173
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm1, %xmm0	 # _173, _113
	jbe	.L198	 #,
.L217:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	4(%r8), %r9d	 # MEM[(const struct pair &)_172].second, pretmp_592
.L146:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r13,8), %r13	 #, _176
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r9d, 4(%r13)	 # pretmp_592, _176->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm1, 0(%r13)	 # _173, _176->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	leaq	-1(%rdx), %r13	 #, _178
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	movq	%r13, %r9	 # _178, tmp414
	shrq	$63, %r9	 #, tmp414
	addq	%r13, %r9	 # _178, tmp415
	movq	%rdx, %r13	 # __parent, __holeIndex
	sarq	%r9	 # __parent_179
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%rdx, %rdx	 # __holeIndex
	je	.L143	 #,
	movq	%r9, %rdx	 # __parent_179, __parent
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r8	 #, _600
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r8), %xmm1	 # MEM[(const struct pair &)_172].first, _173
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm1, %xmm0	 # _173, _113
	ja	.L217	 #,
.L198:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm0, %xmm1	 # _113, _173
	ja	.L210	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%r8), %r9d	 # MEM[(const struct pair &)_172].second, pretmp_592
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	cmpl	%r11d, %r9d	 # _323, pretmp_592
	jb	.L146	 #,
.L210:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r13,8), %r8	 #, _600
.L143:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r11d, 4(%r8)	 # _323, prephitmp_602->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%r8)	 # _113, prephitmp_602->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%rcx, %r8	 # prephitmp_483, _194
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:262:       _ValueType __value = _GLIBCXX_MOVE(*__result);
	movl	-4(%r10), %edx	 # MEM <unsigned int> [(struct pair &)prephitmp_565 + 18446744073709551612], __value$second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	(%rax), %xmm0	 # prephitmp_571->first, _191
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	subq	%rax, %r8	 # prephitmp_485, _194
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:262:       _ValueType __value = _GLIBCXX_MOVE(*__result);
	vmovss	-8(%r10), %xmm1	 # MEM <float> [(struct pair &)prephitmp_565 + 18446744073709551608], __value$first
	movl	%edx, 56(%rsp)	 # __value$second, %sfp
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	movq	%r8, %r13	 # _194, _195
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	4(%rax), %edx	 # prephitmp_571->second, _192
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1328:     { return __lhs.base() - __rhs.base(); }
	sarq	$3, %r13	 #, _195
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, -8(%r10)	 # _191, MEM[(struct pair *)prephitmp_565 + -8B].first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%edx, -4(%r10)	 # _192, MEM[(struct pair *)prephitmp_565 + -8B].second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	leaq	-1(%r13), %rdx	 #, _124
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	movq	%r13, %r10	 # _195, _694
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	movq	%rdx, %r11	 # _124, tmp421
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	andl	$1, %r10d	 #, _694
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	shrq	$63, %r11	 #, tmp421
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	movq	%r10, 48(%rsp)	 # _694, %sfp
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	addq	%rdx, %r11	 # _124, tmp422
	sarq	%r11	 # _115
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	cmpq	$16, %r8	 #, _194
	jle	.L147	 #,
	movl	%ebx, 60(%rsp)	 # _1, %sfp
	xorl	%r10d, %r10d	 # __holeIndex
	movq	%rdi, 64(%rsp)	 # i, %sfp
	movq	%rcx, 72(%rsp)	 # prephitmp_483, %sfp
	jmp	.L151	 #
	.p2align 6
	.p2align 4,,10
	.p2align 3
.L219:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%r9), %ecx	 # MEM[(const struct pair &)_540].second, prephitmp_524
.L150:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r10,8), %rdx	 #, _521
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%ecx, 4(%rdx)	 # prephitmp_524, _521->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%rdx)	 # prephitmp_525, _521->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	cmpq	%r8, %r11	 # __holeIndex, _115
	jle	.L218	 #,
.L174:
	movq	%r8, %r10	 # __holeIndex, __holeIndex
.L151:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:231: 	  __secondChild = 2 * (__secondChild + 1);
	leaq	1(%r10), %rdx	 #, _545
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:231: 	  __secondChild = 2 * (__secondChild + 1);
	leaq	(%rdx,%rdx), %rbx	 #, __secondChild
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	salq	$4, %rdx	 #, _538
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:232: 	  if (__comp(__first + __secondChild,
	leaq	-1(%rbx), %r8	 #, __holeIndex
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	addq	%rax, %rdx	 # prephitmp_485, _537
	leaq	(%rax,%r8,8), %r9	 #, _650
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%rdx), %xmm3	 # MEM[(const struct pair &)_537].first, _536
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r9), %xmm0	 # MEM[(const struct pair &)_540].first, prephitmp_525
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm3, %xmm0	 # _536, prephitmp_525
	ja	.L219	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm0, %xmm3	 # prephitmp_525, _536
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%rdx), %ecx	 # MEM[(const struct pair &)_537].second, prephitmp_524
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	ja	.L172	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%r9), %edi	 # MEM[(const struct pair &)_540].second, _533
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	cmpl	%edi, %ecx	 # _533, prephitmp_524
	jnb	.L172	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r10,8), %rdx	 #, _521
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	%edi, %ecx	 # _533, prephitmp_524
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%ecx, 4(%rdx)	 # prephitmp_524, _521->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%rdx)	 # prephitmp_525, _521->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:229:       while (__secondChild < (__len - 1) / 2)
	cmpq	%r8, %r11	 # __holeIndex, _115
	jg	.L174	 #,
.L218:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	cmpq	$0, 48(%rsp)	 #, %sfp
	movl	60(%rsp), %ebx	 # %sfp, _1
	movq	64(%rsp), %rdi	 # %sfp, i
	movq	72(%rsp), %rcx	 # %sfp, prephitmp_483
	je	.L155	 #,
.L211:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	leaq	-1(%r8), %r10	 #, _627
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:139:       _Distance __parent = (__holeIndex - 1) / 2;
	movq	%r10, %rdx	 # _627, tmp436
	shrq	$63, %rdx	 #, tmp436
	addq	%r10, %rdx	 # _627, tmp437
	sarq	%rdx	 # prephitmp_591
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%r8, %r8	 # __holeIndex
	je	.L154	 #,
.L161:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r9	 #, _650
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r9), %xmm0	 # MEM[(const struct pair &)_246].first, _247
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm0, %xmm1	 # _247, __value$first
	jbe	.L202	 #,
.L220:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	4(%r9), %r10d	 # MEM[(const struct pair &)_246].second, pretmp_642
.L164:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r8,8), %r8	 #, _250
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r10d, 4(%r8)	 # pretmp_642, _250->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	leaq	-1(%rdx), %r10	 #, _252
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%r8)	 # _247, _250->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:144: 	  __parent = (__holeIndex - 1) / 2;
	movq	%r10, %r8	 # _252, tmp443
	shrq	$63, %r8	 #, tmp443
	addq	%r10, %r8	 # _252, tmp444
	sarq	%r8	 # tmp444
	movq	%r8, %r10	 # tmp444, __parent_253
	movq	%rdx, %r8	 # prephitmp_591, __holeIndex
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:140:       while (__holeIndex > __topIndex && __comp(__first + __parent, __value))
	testq	%rdx, %rdx	 # __holeIndex
	je	.L154	 #,
	movq	%r10, %rdx	 # __parent_253, prephitmp_591
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%rdx,8), %r9	 #, _650
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovss	(%r9), %xmm0	 # MEM[(const struct pair &)_246].first, _247
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm0, %xmm1	 # _247, __value$first
	ja	.L220	 #,
.L202:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	vcomiss	%xmm1, %xmm0	 # __value$first, _247
	ja	.L212	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	4(%r9), %r10d	 # MEM[(const struct pair &)_246].second, pretmp_642
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1047: 	     || (!(__y.first < __x.first) && __x.second < __y.second); }
	movl	56(%rsp), %r11d	 # %sfp, __value$second
	cmpl	%r11d, %r10d	 # __value$second, pretmp_642
	jb	.L164	 #,
.L212:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r8,8), %r9	 #, _650
.L154:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	56(%rsp), %edx	 # %sfp, __value$second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm1, (%r9)	 # __value$first, prephitmp_652->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%edx, 4(%r9)	 # __value$second, prephitmp_652->second
.L140:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1327: 	--this->_M_impl._M_finish;
	movq	%rcx, 8(%r14)	 # prephitmp_483, MEM[(struct vector *)q_14(D)].D.102498._M_impl.D.101799._M_finish
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_queue.h:776:       }
	jmp	.L135	 #
	.p2align 4,,10
	.p2align 3
.L172:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:1046:     { return __x.first < __y.first
	vmovaps	%xmm3, %xmm0	 # _536, prephitmp_525
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	movq	%rdx, %r9	 # _537, _650
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:231: 	  __secondChild = 2 * (__secondChild + 1);
	movq	%rbx, %r8	 # __secondChild, __holeIndex
	jmp	.L150	 #
	.p2align 4,,10
	.p2align 3
.L169:
 # analysis\../flat_scan_avx2.h:33:     for (; i + 32 <= d; i += 32) {
	vxorps	%xmm1, %xmm1, %xmm1	 # _526
	movl	$7, %r9d	 #, _528
 # analysis\../flat_scan_avx2.h:32:     int i = 0;
	xorl	%edx, %edx	 # tmp.540
 # analysis\../flat_scan_avx2.h:28:     __m256 sum1 = _mm256_setzero_ps();
	vmovaps	%ymm1, %ymm2	 #, sum1
 # analysis\../flat_scan_avx2.h:27:     __m256 sum0 = _mm256_setzero_ps();
	vmovaps	%ymm1, %ymm0	 #, sum0
	jmp	.L118	 #
.L155:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	subq	$2, %r13	 #, _223
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	sarq	%r13	 # _224
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	cmpq	%r8, %r13	 # __holeIndex, _224
	jne	.L211	 #,
.L157:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:241: 	  *(__first + __holeIndex) = _GLIBCXX_MOVE(*(__first
	leaq	1(%r8,%r8), %r10	 #, _227
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	(%rax,%r10,8), %rdx	 #, _230
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	(%rdx), %xmm0	 # _230->first, _234
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	4(%rdx), %edx	 # _230->second, _235
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%r9)	 # _234, prephitmp_612->first
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%edx, 4(%r9)	 # _235, prephitmp_612->second
	movq	%r8, %rdx	 # __holeIndex, prephitmp_591
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:243: 	  __holeIndex = __secondChild - 1;
	movq	%r10, %r8	 # _227, __holeIndex
	jmp	.L161	 #
.L126:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:123: 	  _M_realloc_append(std::forward<_Args>(__args)...);
	movl	%edi, 84(%rsp)	 # i, D.104284.second
	leaq	80(%rsp), %rdx	 #, tmp390
	movq	%r14, %rcx	 # <retval>,
	vmovss	%xmm0, 80(%rsp)	 # _113, D.104284.first
	vzeroupper
.LEHB6:
	call	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_	 #
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1068:       : _M_current(__i) { }
	movq	8(%r14), %rcx	 # MEM[(struct pair * const &)q_14(D) + 8], prephitmp_483
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	(%r14), %rax	 # MEM[(struct _Vector_base *)q_14(D)]._M_impl.D.101799._M_start, prephitmp_485
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:215:       _ValueType __value = _GLIBCXX_MOVE(*(__last - 1));
	vmovss	-8(%rcx), %xmm0	 # MEM <float> [(struct pair &)pretmp_656 + 18446744073709551608], _113
	movl	-4(%rcx), %r10d	 # MEM <unsigned int> [(struct pair &)pretmp_656 + 18446744073709551612], _480
	jmp	.L127	 #
.L137:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/vector.tcc:123: 	  _M_realloc_append(std::forward<_Args>(__args)...);
	movl	%edi, 92(%rsp)	 # i, D.104295.second
	leaq	88(%rsp), %rdx	 #, tmp405
	movq	%r14, %rcx	 # <retval>,
	vmovss	%xmm0, 88(%rsp)	 # _113, D.104295.first
	vzeroupper
	call	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJS1_EEEvDpOT_	 #
.LEHE6:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1068:       : _M_current(__i) { }
	movq	8(%r14), %r10	 # MEM[(struct pair * const &)q_14(D) + 8], _154
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	(%r14), %rax	 # MEM[(struct _Vector_base *)q_14(D)]._M_impl.D.101799._M_start, prephitmp_485
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:215:       _ValueType __value = _GLIBCXX_MOVE(*(__last - 1));
	movl	-4(%r10), %r11d	 # MEM <unsigned int> [(struct pair &)pretmp_564 + 18446744073709551612], _323
	vmovss	-8(%r10), %xmm0	 # MEM <float> [(struct pair &)pretmp_564 + 18446744073709551608], _113
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:1327: 	--this->_M_impl._M_finish;
	leaq	-8(%r10), %rcx	 #, prephitmp_483
	jmp	.L138	 #
.L216:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_iterator.h:1139:       { return __normal_iterator(_M_current + __n); }
	leaq	-8(%rax,%r9), %rdx	 #, _334
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:938: 	second = std::forward<second_type>(__p.second);
	movl	%r11d, 4(%rdx)	 # _323, _334->second
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_pair.h:937: 	first = std::forward<first_type>(__p.first);
	vmovss	%xmm0, (%rdx)	 # _113, _334->first
	jmp	.L140	 #
.L147:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	cmpq	$0, 48(%rsp)	 #, %sfp
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	movq	%rax, %r9	 # prephitmp_485, _650
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	jne	.L154	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_heap.h:238:       if ((__len & 1) == 0 && __secondChild == (__len - 2) / 2)
	cmpq	$2, %rdx	 #, _124
	ja	.L154	 #,
	xorl	%r8d, %r8d	 # __holeIndex
	jmp	.L157	 #
.L177:
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	(%r14), %rcx	 # MEM[(struct _Vector_base *)q_14(D)]._M_impl.D.101799._M_start, _34
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	16(%r14), %rdx	 # MEM[(struct _Vector_base *)q_14(D)]._M_impl.D.101799._M_end_of_storage, MEM[(struct _Vector_base *)q_14(D)]._M_impl.D.101799._M_end_of_storage
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	movq	%rax, %rbx	 # tmp458, tmp449
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:369: 		      _M_impl._M_end_of_storage - _M_impl._M_start);
	subq	%rcx, %rdx	 # _34, _35
 # C:/msys64/mingw64/include/c++/14.2.0/bits/stl_vector.h:388: 	if (__p)
	testq	%rcx, %rcx	 # _34
	je	.L208	 #,
 # C:/msys64/mingw64/include/c++/14.2.0/bits/new_allocator.h:172: 	_GLIBCXX_OPERATOR_DELETE(_GLIBCXX_SIZED_DEALLOC(__p, __n));
	vzeroupper
	call	_ZdlPvy	 #
.L168:
	movq	%rbx, %rcx	 # tmp449,
.LEHB7:
	call	_Unwind_Resume	 #
.LEHE7:
.L208:
	vzeroupper
	jmp	.L168	 #
	.seh_handler	__gxx_personality_seh0, @unwind, @except
	.seh_handlerdata
.LLSDA9625:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE9625-.LLSDACSB9625
.LLSDACSB9625:
	.uleb128 .LEHB6-.LFB9625
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L177-.LFB9625
	.uleb128 0
	.uleb128 .LEHB7-.LFB9625
	.uleb128 .LEHE7-.LEHB7
	.uleb128 0
	.uleb128 0
.LLSDACSE9625:
	.text
	.seh_endproc
	.section .rdata,"dr"
	.align 4
.LC1:
	.long	1065353216
	.align 4
.LC2:
	.long	1206984704
	.align 32
.LC6:
	.long	0
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.align 4
.LC11:
	.long	981668463
	.align 4
.LC16:
	.long	990057071
	.set	.LC17,.LC6
	.align 4
.LC36:
	.long	354224107
	.align 4
.LC37:
	.long	97
	.set	.LC38,.LC6+4
	.align 4
.LC39:
	.long	-1206451487
	.align 4
.LC40:
	.long	89
	.set	.LC41,.LC6+12
	.def	__gxx_personality_seh0;	.scl	2;	.type	32;	.endef
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev3, Built by MSYS2 project) 14.2.0"
	.def	_ZNSt6chrono3_V212system_clock3nowEv;	.scl	2;	.type	32;	.endef
	.def	strlen;	.scl	2;	.type	32;	.endef
	.def	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_x;	.scl	2;	.type	32;	.endef
	.def	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate;	.scl	2;	.type	32;	.endef
	.def	_Znwy;	.scl	2;	.type	32;	.endef
	.def	memset;	.scl	2;	.type	32;	.endef
	.def	_ZSt20__throw_length_errorPKc;	.scl	2;	.type	32;	.endef
	.def	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv;	.scl	2;	.type	32;	.endef
	.def	_ZNSolsEi;	.scl	2;	.type	32;	.endef
	.def	_ZNSo9_M_insertIdEERSoT_;	.scl	2;	.type	32;	.endef
	.def	_ZdlPvy;	.scl	2;	.type	32;	.endef
	.def	atoi;	.scl	2;	.type	32;	.endef
	.def	_Unwind_Resume;	.scl	2;	.type	32;	.endef
	.section	.rdata$.refptr._ZSt4cout, "dr"
	.globl	.refptr._ZSt4cout
	.linkonce	discard
.refptr._ZSt4cout:
	.quad	_ZSt4cout
