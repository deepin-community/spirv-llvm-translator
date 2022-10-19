; LLVM IR generated by Intel SYCL Clang compiler (https://github.com/intel/llvm)
; SYCL source code can be found below:

; #define BURST_COAL 0x1
; #define CACHE_SIZE_FLAG 0x2
; #define DONT_STATICALLY_COAL 0x4
; #define PREFETCH 0x8
; struct State {
;   float Field1;
;   int Field2;
; };
;
; void foo(float *A, int *B, State *C) {
;   float *x;
;   int *y;
;   State *z;
;   double *t;
;   x = __builtin_intel_fpga_mem(A, BURST_COAL | CACHE_SIZE_FLAG, 0);
;   y = __builtin_intel_fpga_mem(B, DONT_STATICALLY_COAL | PREFETCH, 0);
;   z = __builtin_intel_fpga_mem(C, CACHE_SIZE_FLAG, 127);
;   x = __builtin_intel_fpga_mem(&C->Field1, BURST_COAL | CACHE_SIZE_FLAG, 127);
;   y = __builtin_intel_fpga_mem(&C->Field2, 0, 127);
;   z = __builtin_intel_fpga_mem(C, BURST_COAL | CACHE_SIZE_FLAG | DONT_STATICALLY_COAL | PREFETCH, 127);
;   t = __builtin_intel_fpga_mem((double *) A, BURST_COAL | CACHE_SIZE_FLAG, 0);
;   *__builtin_intel_fpga_mem(A, BURST_COAL | CACHE_SIZE_FLAG, 0) = 5;
;   int s = *__builtin_intel_fpga_mem(B, DONT_STATICALLY_COAL | PREFETCH, 0);
; }
;
; template <typename name, typename Func>
; __attribute__((sycl_kernel)) void kernel_single_task(Func kernelFunc) {
;   kernelFunc();
; }
;
; int main() {
;   kernel_single_task<class fake_kernel>([]() {
;     float *A;
;     int *B;
;     State *C;
;     foo(A, B, C);
;   });
;   return 0;
; }

; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_fpga_memory_accesses -o %t.spv
; RUN: llvm-spirv %t.spv -to-text -o - | FileCheck %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

; CHECK-SPIRV: Capability FPGAMemoryAccessesINTEL
; CHECK-SPIRV: Extension "SPV_INTEL_fpga_memory_accesses"
; Check that the semantically meaningless decoration was
; translated as a mere annotation
; CHECK-SPIRV: Decorate {{[0-9]+}} UserSemantic "{params:0}{cache-size:127}"
; CHECK-SPIRV: Decorate {{[0-9]+}} BurstCoalesceINTEL
; CHECK-SPIRV: Decorate {{[0-9]+}} CacheSizeINTEL 0
; CHECK-SPIRV: Decorate {{[0-9]+}} CacheSizeINTEL 127
; CHECK-SPIRV: Decorate {{[0-9]+}} DontStaticallyCoalesceINTEL
; CHECK-SPIRV: Decorate {{[0-9]+}} PrefetchINTEL 0

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

%"class._ZTSZ4mainE3$_0.anon" = type { i8 }
%struct._ZTS5State.State = type { float, i32 }

; CHECK-LLVM: [[PARAM_3_CACHE_0:@[a-z0-9_.]+]] = {{.*}}{params:3}{cache-size:0}
@.str = private unnamed_addr constant [25 x i8] c"{params:3}{cache-size:0}\00", section "llvm.metadata"
@.str.1 = private unnamed_addr constant [14 x i8] c"<invalid loc>\00", section "llvm.metadata"
; "params" bitmask doesn't hold 0x2 (cache size ON), so cache-size can be dropped
; during translation
; CHECK-LLVM: [[PARAM_12_CACHE_0:@[a-z0-9_.]+]] = {{.*}}{params:12}
@.str.2 = private unnamed_addr constant [26 x i8] c"{params:12}{cache-size:0}\00", section "llvm.metadata"
; CHECK-LLVM: [[PARAM_2_CACHE_127:@[a-z0-9_.]+]] = {{.*}}{params:2}{cache-size:127}
@.str.3 = private unnamed_addr constant [27 x i8] c"{params:2}{cache-size:127}\00", section "llvm.metadata"
; CHECK-LLVM: [[PARAM_3_CACHE_127:@[a-z0-9_.]+]] = {{.*}}{params:3}{cache-size:127}
@.str.4 = private unnamed_addr constant [27 x i8] c"{params:3}{cache-size:127}\00", section "llvm.metadata"
; Since "params" bitmask is set to 0, the next string isn't required to be preserved
; during translation. Neither is the corresponding pointer annotation intrinsic.
@.str.5 = private unnamed_addr constant [27 x i8] c"{params:0}{cache-size:127}\00", section "llvm.metadata"
; CHECK-LLVM: [[PARAM_15_CACHE_127:@[a-z0-9_.]+]] = {{.*}}{params:15}{cache-size:127}
@.str.6 = private unnamed_addr constant [28 x i8] c"{params:15}{cache-size:127}\00", section "llvm.metadata"
; TODO: Investigate why the same global annotation string shows up twice in backwards translation.
; CHECK-LLVM: [[PARAM_3_CACHE_0_DOUBLE:@[a-z0-9_.]+]] = {{.*}}{params:3}{cache-size:0}
; CHECK-LLVM: [[PARAM_3_CACHE_0_DOUBLE2:@[a-z0-9_.]+]] = {{.*}}{params:3}{cache-size:0}
; CHECK-LLVM: [[PARAM_12_CACHE_0_DOUBLE:@[a-z0-9_.]+]] = {{.*}}{params:12}

; Function Attrs: norecurse nounwind
define spir_kernel void @_ZTSZ4mainE11fake_kernel() #0 !kernel_arg_addr_space !4 !kernel_arg_access_qual !4 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !4 {
entry:
  %0 = alloca %"class._ZTSZ4mainE3$_0.anon", align 1
  %1 = bitcast %"class._ZTSZ4mainE3$_0.anon"* %0 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %1) #5
  %2 = addrspacecast %"class._ZTSZ4mainE3$_0.anon"* %0 to %"class._ZTSZ4mainE3$_0.anon" addrspace(4)*
  call spir_func void @"_ZZ4mainENK3$_0clEv"(%"class._ZTSZ4mainE3$_0.anon" addrspace(4)* %2)
  %3 = bitcast %"class._ZTSZ4mainE3$_0.anon"* %0 to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %3) #5
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: inlinehint norecurse nounwind
define internal spir_func void @"_ZZ4mainENK3$_0clEv"(%"class._ZTSZ4mainE3$_0.anon" addrspace(4)* %this) #2 align 2 {
entry:
  %this.addr = alloca %"class._ZTSZ4mainE3$_0.anon" addrspace(4)*, align 8
  %A = alloca float addrspace(4)*, align 8
  %B = alloca i32 addrspace(4)*, align 8
  %C = alloca %struct._ZTS5State.State addrspace(4)*, align 8
  store %"class._ZTSZ4mainE3$_0.anon" addrspace(4)* %this, %"class._ZTSZ4mainE3$_0.anon" addrspace(4)** %this.addr, align 8, !tbaa !5
  %0 = bitcast float addrspace(4)** %A to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #5
  %1 = bitcast i32 addrspace(4)** %B to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1) #5
  %2 = bitcast %struct._ZTS5State.State addrspace(4)** %C to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #5
  %3 = load float addrspace(4)*, float addrspace(4)** %A, align 8, !tbaa !5
  %4 = load i32 addrspace(4)*, i32 addrspace(4)** %B, align 8, !tbaa !5
  %5 = load %struct._ZTS5State.State addrspace(4)*, %struct._ZTS5State.State addrspace(4)** %C, align 8, !tbaa !5
  call spir_func void @_Z3fooPfPiP5State(float addrspace(4)* %3, i32 addrspace(4)* %4, %struct._ZTS5State.State addrspace(4)* %5)
  %6 = bitcast %struct._ZTS5State.State addrspace(4)** %C to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %6) #5
  %7 = bitcast i32 addrspace(4)** %B to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %7) #5
  %8 = bitcast float addrspace(4)** %A to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %8) #5
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; CHECK-LLVM: define spir_func void @{{.*}}foo
; Function Attrs: norecurse nounwind
define spir_func void @_Z3fooPfPiP5State(float addrspace(4)* %A, i32 addrspace(4)* %B, %struct._ZTS5State.State addrspace(4)* %C) #3 {
entry:
; CHECK-LLVM: %[[FLOAT_FUNC_PARAM:[[:alnum:].]+]] = alloca float addrspace(4)*, align 8
; CHECK-LLVM: %[[INT_FUNC_PARAM:[[:alnum:].]+]] = alloca i32 addrspace(4)*, align 8
; CHECK-LLVM: %[[STRUCT_FUNC_PARAM:[[:alnum:].]+]] = alloca %struct{{.*}}State addrspace(4)*, align 8
  %A.addr = alloca float addrspace(4)*, align 8
  %B.addr = alloca i32 addrspace(4)*, align 8
  %C.addr = alloca %struct._ZTS5State.State addrspace(4)*, align 8
; CHECK-LLVM: %[[FLOAT_VAR:[[:alnum:].]+]] = alloca float addrspace(4)*, align 8
; CHECK-LLVM: %[[INT_VAR:[[:alnum:].]+]] = alloca i32 addrspace(4)*, align 8
; CHECK-LLVM: %[[STRUCT_VAR:[[:alnum:].]+]] = alloca %struct{{.*}}State addrspace(4)*, align 8
; CHECK-LLVM: %[[DOUBLE_VAR:[[:alnum:].]+]] = alloca double addrspace(4)*, align 8
; CHECK-LLVM: %[[INT_VAR_1:[[:alnum:].]+]] = alloca i32, align 4
  %x = alloca float addrspace(4)*, align 8
  %y = alloca i32 addrspace(4)*, align 8
  %z = alloca %struct._ZTS5State.State addrspace(4)*, align 8
  %t = alloca double addrspace(4)*, align 8
  %s = alloca i32, align 4
  store float addrspace(4)* %A, float addrspace(4)** %A.addr, align 8, !tbaa !5
  store i32 addrspace(4)* %B, i32 addrspace(4)** %B.addr, align 8, !tbaa !5
  store %struct._ZTS5State.State addrspace(4)* %C, %struct._ZTS5State.State addrspace(4)** %C.addr, align 8, !tbaa !5
  %0 = bitcast float addrspace(4)** %x to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #5
  %1 = bitcast i32 addrspace(4)** %y to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1) #5
  %2 = bitcast %struct._ZTS5State.State addrspace(4)** %z to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #5
; CHECK-LLVM: %[[FLOAT_FUNC_PARAM_LOAD:[[:alnum:].]+]] = load float addrspace(4)*, float addrspace(4)** %[[FLOAT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %[[FLOAT_FUNC_PARAM_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_3_CACHE_0]]
; CHECK-LLVM: store float addrspace(4)* %[[INTRINSIC_CALL]], float addrspace(4)** %[[FLOAT_VAR]]
  %3 = load float addrspace(4)*, float addrspace(4)** %A.addr, align 8, !tbaa !5
  %4 = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %3, i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store float addrspace(4)* %4, float addrspace(4)** %x, align 8, !tbaa !5
; CHECK-LLVM: %[[INT_FUNC_PARAM_LOAD:[[:alnum:].]+]] = load i32 addrspace(4)*, i32 addrspace(4)** %[[INT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)* %[[INT_FUNC_PARAM_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_12_CACHE_0]]
; CHECK-LLVM: store i32 addrspace(4)* %[[INTRINSIC_CALL]], i32 addrspace(4)** %[[INT_VAR]]
  %5 = load i32 addrspace(4)*, i32 addrspace(4)** %B.addr, align 8, !tbaa !5
  %6 = call i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)* %5, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store i32 addrspace(4)* %6, i32 addrspace(4)** %y, align 8, !tbaa !5
; CHECK-LLVM: %[[WHOLE_STRUCT_LOAD:[0-9]+]] = [[WHOLE_STRUCT_LOAD_INST:load\ %struct.*State\ addrspace\(4\)\*,\ %struct.*State\ addrspace\(4\)\*\*.*]][[STRUCT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call %struct{{.*}}State addrspace(4)* @llvm.ptr.annotation.p4s_struct{{.*}}States(%struct{{.*}}State addrspace(4)* %[[WHOLE_STRUCT_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_2_CACHE_127]]
; CHECK-LLVM: store %struct{{.*}}State addrspace(4)* %[[INTRINSIC_CALL]], %struct{{.*}}State addrspace(4)** %[[STRUCT_VAR]]
  %7 = load %struct._ZTS5State.State addrspace(4)*, %struct._ZTS5State.State addrspace(4)** %C.addr, align 8, !tbaa !5
  %8 = call %struct._ZTS5State.State addrspace(4)* @llvm.ptr.annotation.p4s_struct._ZTS5State.States(%struct._ZTS5State.State addrspace(4)* %7, i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.3, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store %struct._ZTS5State.State addrspace(4)* %8, %struct._ZTS5State.State addrspace(4)** %z, align 8, !tbaa !5
; CHECK-LLVM: %[[WHOLE_STRUCT_LOAD_FOR_FLOAT:[0-9]+]] = [[WHOLE_STRUCT_LOAD_INST]][[STRUCT_FUNC_PARAM]]
; CHECK-LLVM: %[[FLOAT_FIELD_GEP:[[:alnum:].]+]] = getelementptr inbounds %struct{{.*}}State, %struct{{.*}}State addrspace(4)* %[[WHOLE_STRUCT_LOAD_FOR_FLOAT]], i32 0, i32 0
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %[[FLOAT_FIELD_GEP]], i8* getelementptr inbounds ({{.*}} [[PARAM_3_CACHE_127]]
; CHECK-LLVM: store float addrspace(4)* %[[INTRINSIC_CALL]], float addrspace(4)** %[[FLOAT_VAR]]
  %9 = load %struct._ZTS5State.State addrspace(4)*, %struct._ZTS5State.State addrspace(4)** %C.addr, align 8, !tbaa !5
  %Field1 = getelementptr inbounds %struct._ZTS5State.State, %struct._ZTS5State.State addrspace(4)* %9, i32 0, i32 0
  %10 = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %Field1, i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.4, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store float addrspace(4)* %10, float addrspace(4)** %x, align 8, !tbaa !5
; CHECK-LLVM: %[[WHOLE_STRUCT_LOAD_FOR_INT:[0-9]+]] = [[WHOLE_STRUCT_LOAD_INST]][[STRUCT_FUNC_PARAM]]
; CHECK-LLVM: %[[INT_FIELD_GEP:[[:alnum:].]+]] = getelementptr inbounds %struct{{.*}}State, %struct{{.*}}State addrspace(4)* %[[WHOLE_STRUCT_LOAD_FOR_INT]], i32 0, i32 1
; The annotation for the succeeding intrinsic isn't required to be preserved
; during translation
; CHECK-LLVM: store i32 addrspace(4)* %{{.*}}, i32 addrspace(4)** %[[INT_VAR]]
  %11 = load %struct._ZTS5State.State addrspace(4)*, %struct._ZTS5State.State addrspace(4)** %C.addr, align 8, !tbaa !5
  %Field2 = getelementptr inbounds %struct._ZTS5State.State, %struct._ZTS5State.State addrspace(4)* %11, i32 0, i32 1
  %12 = call i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)* %Field2, i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.5, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store i32 addrspace(4)* %12, i32 addrspace(4)** %y, align 8, !tbaa !5
; CHECK-LLVM: %[[WHOLE_STRUCT_LOAD:[0-9]+]] = [[WHOLE_STRUCT_LOAD_INST]][[STRUCT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call %struct{{.*}}State addrspace(4)* @llvm.ptr.annotation.p4s_struct{{.*}}States(%struct{{.*}}State addrspace(4)* %[[WHOLE_STRUCT_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_15_CACHE_127]]
; CHECK-LLVM: store %struct{{.*}}State addrspace(4)* %[[INTRINSIC_CALL]], %struct{{.*}}State addrspace(4)** %[[STRUCT_VAR]]
  %13 = load %struct._ZTS5State.State addrspace(4)*, %struct._ZTS5State.State addrspace(4)** %C.addr, align 8, !tbaa !5
  %14 = call %struct._ZTS5State.State addrspace(4)* @llvm.ptr.annotation.p4s_struct._ZTS5State.States(%struct._ZTS5State.State addrspace(4)* %13, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.6, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store %struct._ZTS5State.State addrspace(4)* %14, %struct._ZTS5State.State addrspace(4)** %z, align 8, !tbaa !5
  %15 = bitcast double addrspace(4)** %t to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %15) #5
; CHECK-LLVM: %[[FLOAT_FUNC_PARAM_LOAD:[[:alnum:].]+]] = load float addrspace(4)*, float addrspace(4)** %[[FLOAT_FUNC_PARAM]]
; CHECK-LLVM: %[[BITCAST_FLOAT_TO_DOUBLE:[[:alnum:].]+]] = bitcast float addrspace(4)* %[[FLOAT_FUNC_PARAM_LOAD]] to double addrspace(4)*
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call double addrspace(4)* @llvm.ptr.annotation.p4f64(double addrspace(4)* %[[BITCAST_FLOAT_TO_DOUBLE]], i8* getelementptr inbounds ({{.*}} [[PARAM_3_CACHE_0_DOUBLE]]
; CHECK-LLVM: store double addrspace(4)* %[[INTRINSIC_CALL]], double addrspace(4)** %[[DOUBLE_VAR]]
  %16 = load float addrspace(4)*, float addrspace(4)** %A.addr, align 8, !tbaa !5
  %17 = bitcast float addrspace(4)* %16 to double addrspace(4)*
  %18 = call double addrspace(4)* @llvm.ptr.annotation.p4f64(double addrspace(4)* %17, i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store double addrspace(4)* %18, double addrspace(4)** %t, align 8, !tbaa !5
; CHECK-LLVM: %[[FLOAT_FUNC_PARAM_LOAD:[[:alnum:].]+]] = load float addrspace(4)*, float addrspace(4)** %[[FLOAT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %[[FLOAT_FUNC_PARAM_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_3_CACHE_0_DOUBLE2]]
; CHECK-LLVM: store float 5.000000e+00, float addrspace(4)* %[[INTRINSIC_CALL]]
  %19 = load float addrspace(4)*, float addrspace(4)** %A.addr, align 8, !tbaa !5
  %20 = call float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)* %19, i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  store float 5.000000e+00, float addrspace(4)* %20, align 4, !tbaa !5
  %21 = bitcast i32* %s to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #5
; CHECK-LLVM: %[[INT1_FUNC_PARAM_LOAD:[[:alnum:].]+]] = load i32 addrspace(4)*, i32 addrspace(4)** %[[INT_FUNC_PARAM]]
; CHECK-LLVM: %[[INTRINSIC_CALL:[[:alnum:].]+]] = call i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)* %[[INT1_FUNC_PARAM_LOAD]], i8* getelementptr inbounds ({{.*}} [[PARAM_12_CACHE_0_DOUBLE]]
; CHECK-LLVM: %[[INTRINSIC_RESULT_LOAD:[[:alnum:].]+]] = load i32, i32 addrspace(4)* %[[INTRINSIC_CALL]]
; CHECK-LLVM: store i32 %[[INTRINSIC_RESULT_LOAD]], i32* %[[INT_VAR_1]]
  %22 = load i32 addrspace(4)*, i32 addrspace(4)** %B.addr, align 8, !tbaa !5
  %23 = call i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)* %22, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i32 0, i32 0), i32 0, i8* null) #6
  %24 = load i32, i32 addrspace(4)* %23, align 4, !tbaa !5
  store i32 %24, i32* %s, align 4, !tbaa !5
  %25 = bitcast i32* %s to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %25) #5
  %26 = bitcast double addrspace(4)** %t to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %26) #5
  %27 = bitcast %struct._ZTS5State.State addrspace(4)** %z to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %27) #5
  %28 = bitcast i32 addrspace(4)** %y to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %28) #5
  %29 = bitcast float addrspace(4)** %x to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %29) #5
  ret void
}

; Function Attrs: nounwind willreturn
declare float addrspace(4)* @llvm.ptr.annotation.p4f32(float addrspace(4)*, i8*, i8*, i32, i8*) #4

; Function Attrs: nounwind willreturn
declare i32 addrspace(4)* @llvm.ptr.annotation.p4i32(i32 addrspace(4)*, i8*, i8*, i32, i8*) #4

; Function Attrs: nounwind willreturn
declare %struct._ZTS5State.State addrspace(4)* @llvm.ptr.annotation.p4s_struct._ZTS5State.States(%struct._ZTS5State.State addrspace(4)*, i8*, i8*, i32, i8*) #4

; Function Attrs: nounwind willreturn
declare double addrspace(4)* @llvm.ptr.annotation.p4f64(double addrspace(4)*, i8*, i8*, i32, i8*) #4

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "sycl-module-id"="/tmp/lsu.cpp" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { inlinehint norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind willreturn }
attributes #5 = { nounwind }
attributes #6 = { readnone }

!llvm.module.flags = !{!0}
!opencl.spir.version = !{!1}
!spirv.Source = !{!2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, i32 2}
!2 = !{i32 4, i32 100000}
!3 = !{!"clang version 11.0.0"}
!4 = !{}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
