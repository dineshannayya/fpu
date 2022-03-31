//-------------------------------------
// Single Precision Type cast functions
//   *F2I - Floating to Int
//   *I2F - Int to Float
//-------------------------------------

#include <stdlib.h> /* ANSI C standard library */
#include <stdio.h> /* ANSI C standard input/output library */
#include <stdarg.h> /* ANSI C standard arguments library */
#include  "vpi_user.h"  /*  IEEE 1364 PLI VPI routine library  */

#define CMD_FPU_SP_F2I 4  // Single Precision (32 bit) Float to Integer
#define CMD_FPU_SP_I2F 5  // Single Precision (32 bit) Integer to Float

/* prototypes of PLI application routine names */
PLI_INT32 PLIbook_FpuAddSizetf(PLI_BYTE8  *user_data),
    PLIbook_FpuAddCalltf(PLI_BYTE8  *user_data),
    PLIbook_FpuAddCompiletf(PLI_BYTE8  *user_data),
    PLIbook_FpuAddStartOfSim(s_cb_data  *callback_data);

/*******************************************
* Sizetf application
* *****************************************/
PLI_INT32  PLIbook_FpuAddSizetf(PLI_BYTE8  *user_data)
{
   return(32); /* $fpu_add returns 32-bit values */
}

/*********************************************
* compiletf application to verify valid systf args.
* *************************************************/
PLI_INT32  PLIbook_FpuAddCompiletf(PLI_BYTE8  *user_data)
{
   vpiHandle systf_handle, arg_itr, arg_handle;
   PLI_INT32 tfarg_type;
   int err_flag = 0;
   do { /* group all tests, so can break out of group on error */
       systf_handle = vpi_handle(vpiSysTfCall, NULL);
       arg_itr = vpi_iterate(vpiArgument, systf_handle);
       if (arg_itr == NULL) {
       vpi_printf("ERROR: $c_fpu_tc requires 2 arguments; has none\n");
       err_flag = 1;
       break;
   }
   arg_handle = vpi_scan(arg_itr);
   tfarg_type = vpi_get(vpiType, arg_handle);
   if ( (tfarg_type != vpiReg) &&
       (tfarg_type != vpiIntegerVar) &&
       (tfarg_type != vpiConstant) ) {
       vpi_printf("ERROR: $c_fpu_tc arg1 must be number, variable or net\n");
       err_flag = 1;
       break;
   }
   
   arg_handle = vpi_scan(arg_itr);
   if (arg_handle == NULL) {
      vpi_printf("ERROR: $c_fpu_tc requires 2nd argument\n");
      err_flag = 1;
      break;
   }
   tfarg_type = vpi_get(vpiType, arg_handle);
   if ( (tfarg_type != vpiReg) &&
      (tfarg_type != vpiIntegerVar) &&
      (tfarg_type != vpiConstant) ) {
      vpi_printf("ERROR: $c_fpu_tc arg2 must be number, variable or net\n");
      err_flag = 1;
      break;
   }

   if (vpi_scan(arg_itr) != NULL) {
       vpi_printf("ERROR: $c_fpu_tc requires 2 arguments; has too many\n");
       vpi_free_object(arg_itr);
       err_flag = 1;
       break;
   }
   } while (0 == 1); /* end of test group; only executed once */
   if (err_flag) {
      vpi_control(vpiFinish, 1);  /* abort simulation */
   }
   return(0);
}

/******************************************************************
* calltf to calculate floating point addr
* ******************************************************************/
#include <math.h>
PLI_INT32  PLIbook_FpuAddCalltf(PLI_BYTE8  *user_data)
{
   s_vpi_value value_s;
   vpiHandle systf_handle,  arg_itr,  arg_handle;
   PLI_INT32 cmd,din;
   float result;
   int c;
   systf_handle = vpi_handle(vpiSysTfCall, NULL);
   arg_itr = vpi_iterate(vpiArgument, systf_handle);
   if (arg_itr == NULL) {
       vpi_printf("ERROR:  $c_fpu_tc failed to obtain systf arg handles\n");
       return(0);
   }
   /* read cmd from systf arg 1 (compiletf has already verified) */
   arg_handle = vpi_scan(arg_itr);
   value_s.format = vpiIntVal;
   vpi_get_value(arg_handle, &value_s);
   cmd = value_s.value.integer;

   
   /* read input1 from systf arg 2 (compiletf has already verified) */
   arg_handle = vpi_scan(arg_itr);
   vpi_get_value(arg_handle,  &value_s);
   din = value_s.value.integer;

   /* add floating point inputs */
   if(cmd == CMD_FPU_SP_F2I) {
	result = *((float*)&din);
        c = (int) result;
        vpi_printf("c-func: Floating Float 2 integer: Input: %f  Result: %d\n",result,c);
   } else if(cmd == CMD_FPU_SP_I2F)  {
	result = (float) din;
        c  = *((int*)&result);
        vpi_printf("c-func: Floating Int 2 Float: Input: %d Result: %f\n",din,result);
   } 
   /* write result to simulation as return value $fpu_add */
   value_s.value.integer =  (PLI_INT32)c;
   vpi_put_value(systf_handle,  &value_s, NULL, vpiNoDelay);
   return(0);
}


/**
* Start-of-simulation application
****/
PLI_INT32  PLIbook_FpuAddStartOfSim(s_cb_data  *callback_data)
{
   vpi_printf("\n$c_fpu_tc PLI application is being used.\n\n");
   return(0);
}

/**********************************************************
    $fpu_add Registration Data
(add this function name to the vlog_startup_routines array)
***********************************************************/
void  PLIbook_fpu_add_register()
{
    s_vpi_systf_data tf_data;
    s_cb_data cb_data_s;
    vpiHandle callback_handle;
    
    tf_data.type = vpiSysFunc;
    tf_data.sysfunctype = vpiSysFuncSized;
    tf_data.tfname =  "$c_fpu_sp_tc";
    tf_data.calltf = PLIbook_FpuAddCalltf;
    tf_data.compiletf = PLIbook_FpuAddCompiletf;
    tf_data.sizetf = PLIbook_FpuAddSizetf;
    tf_data.user_data = NULL;
    vpi_register_systf(&tf_data);
    cb_data_s.reason = cbStartOfSimulation;
    cb_data_s.cb_rtn = PLIbook_FpuAddStartOfSim;
    cb_data_s.obj = NULL;
    cb_data_s.time = NULL;
    cb_data_s.value = NULL;
    cb_data_s.user_data = NULL;
    callback_handle = vpi_register_cb(&cb_data_s);
    vpi_free_object(callback_handle); /* don’t need callback handle */
}

void (*vlog_startup_routines[])() = {
    PLIbook_fpu_add_register,
    0
};

