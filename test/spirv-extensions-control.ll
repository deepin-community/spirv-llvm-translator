; Bunch of negative tests:
;
; RUN: not llvm-spirv --spirv-ext=EXT 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-FORMAT
; RUN: not llvm-spirv --spirv-ext=+EXT 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-EXT
; RUN: not llvm-spirv --spirv-ext=-EXT 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-EXT
; RUN: not llvm-spirv --spirv-ext=- 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-FORMAT
; RUN: not llvm-spirv --spirv-ext=+ 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-FORMAT
; RUN: not llvm-spirv --spirv-ext=, 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-FORMAT
; RUN: not llvm-spirv --spirv-ext= 2>&1 | FileCheck %s --check-prefix=CHECK-INVALID-FORMAT
;
; Bunch of positive tests:
; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+all -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=-all -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_subgroups -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=-SPV_INTEL_subgroups -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=+all,-SPV_INTEL_subgroups -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=-all,+SPV_INTEL_subgroups -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
; RUN: llvm-spirv %t.bc --spirv-ext=-SPV_INTEL_subgroups,+SPV_INTEL_subgroups -o - 2>&1 | FileCheck %s --check-prefix=CHECK-VALID
;
; CHECK-INVALID-FORMAT: Invalid value of --spirv-ext
; CHECK-INVALID-EXT: Unknown extension 'EXT' was specified
;
; CHECK-VALID-NOT: Unknown extension '{{.*}}' was specified

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

; Function Attrs: nounwind
define spir_kernel void @foo(i32 addrspace(1)* %a) #0 !kernel_arg_addr_space !1 !kernel_arg_access_qual !2 !kernel_arg_type !3 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 {
entry:
  %a.addr = alloca i32 addrspace(1)*, align 4
  store i32 addrspace(1)* %a, i32 addrspace(1)** %a.addr, align 4
  ret void
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!opencl.enable.FP_CONTRACT = !{}
!opencl.spir.version = !{!6}
!opencl.ocl.version = !{!6}
!opencl.used.extensions = !{!7}
!opencl.used.optional.core.features = !{!7}
!opencl.compiler.options = !{!7}

!1 = !{i32 1}
!2 = !{!"none"}
!3 = !{!"int*"}
!4 = !{!"int*"}
!5 = !{!""}
!6 = !{i32 1, i32 2}
!7 = !{}

