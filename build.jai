#run, stallable {
	workspace := compiler_create_workspace("Performance");
	if !workspace return;
	
	project_root := #filepath;
	
	{
		using options := get_build_options(workspace);
		
		output_path = project_root;
		output_executable_name = "performance";
		text_output_flags = 0;
		
		backend = .LLVM;
		optimization_level = .RELEASE;
		
		x64_options.enable_register_allocation = true;
		
		array_bounds_check = .OFF;
		cast_bounds_check  = .OFF;
		math_bounds_check  = .OFF;
		null_pointer_check = .OFF;
		
		using llvm_options;
		disable_inlining = true;
		enable_loop_unrolling = false;
		enable_slp_vectorization = false;
		enable_loop_vectorization = false;
		reroll_loops = false;
		
		merge_functions = false;
		enable_split_modules = false;
		
		code_gen_optimization_level = 3;
		code_gen_size_level = 2;
		
		options.import_path = get_build_options().import_path;
		set_build_options(options, workspace);
	}
	
	add_build_file("performance.jai", workspace);
		
	set_build_options_dc(.{do_output=false});
}

#import "Compiler";
#import "Basic";
#import "String";