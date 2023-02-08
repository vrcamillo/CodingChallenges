N :: 100000;
data: [32 * 1024] u32 #align 64;

single :: () -> u32 {
	sum: u32 = 0;
	
	for 0..data.count-1 {
		sum += data[it];
	}
	
	return sum;
}

dual :: () -> u32 {
	sum0: u32 = 0;
	sum1: u32 = 0;

	cursor := data.data;
	
	for 1..data.count / 2 {
		sum0 += cursor[0];
		sum1 += cursor[1];
		cursor += 2;
	}
	
	return sum0 + sum1;
}

quad :: () -> u32 {
	sum0: u32 = 0;
	sum1: u32 = 0;
	sum2: u32 = 0;
	sum3: u32 = 0;
		
	cursor := data.data;
	
	for 1..data.count / 4 {
		sum0 += cursor[0];
		sum1 += cursor[1];
		sum2 += cursor[2];
		sum3 += cursor[3];
		cursor += 4;
	}
	
	return sum0 + sum1 + sum2 + sum3;
}

single_sse :: () -> u32 {	
	#asm {
		xorps.x sum:, sum;
	}

	cursor := data.data;
	for 1..data.count / 4 {
		#asm {
			paddd.x sum, [cursor];
			add cursor, 16;
		}
	}
	
	result: u32 = ---;
	#asm {
		phaddd.x sum, sum;
		phaddd.x sum, sum;
		
		movq result, sum;
	}
	
	return result;
}

dual_sse :: () -> u32 {	
	#asm {
		xorps.x sum0:, sum0;
		xorps.x sum1:, sum1;
	}
	
	cursor := data.data;
	for 1..data.count / 8 {
		#asm {
			paddd.x sum0, [cursor];
			paddd.x sum1, [cursor + 16];
			add cursor, 32;
		}
	}
	
	result: u32 = ---;
	#asm {
		paddd.x sum0, sum1;
		
		phaddd.x sum0, sum0;
		phaddd.x sum0, sum0;
		
		movq result, sum0;
	}
	
	return result;
}

single_avx :: () -> u32 {	
	#asm AVX, AVX2 {
		pxor.y sum:, sum, sum;
	}
	
	cursor := data.data;
	for 1..data.count / 8 {
		#asm AVX2 {
			paddd.y sum, sum, [cursor];
			add cursor, 32;
		}
	}
		
	result: u32 = ---;
	#asm AVX, AVX2 {
		phaddd.y sum, sum, sum;
		phaddd.y sum, sum, sum;
		
		perm2i128 p:, sum, sum, 0b10001;
		paddd.y sum, sum, p;
		
		movd result, sum;
	}
	
	return result;
}

dual_avx :: () -> u32 {	
	#asm AVX2 {
		pxor.y sum0:, sum0, sum0;
		pxor.y sum1:, sum1, sum1;
	}
	
	cursor := data.data;
	for 1..data.count / 16 {
		#asm AVX2 {
			paddd.y sum0, sum0, [cursor];
			paddd.y sum1, sum1, [cursor + 32];
			add cursor, 64;
		}
	}
	
	result: u32 = ---;
	#asm AVX2 {
		paddd.y sum0, sum0, sum1;
		
		phaddd.y sum0, sum0, sum0;
		phaddd.y sum0, sum0, sum0;
		
		perm2i128 p:, sum0, sum0, 0b10001;
		paddd.y sum0, sum0, p;
		
		movd result, sum0;
	}
	
	return result;
}


benchmark :: (function_name: string, is_reference := false) -> float #expand {
	min_time := type_max(s64);
	
	result: u32;
	for 1..N {
		start_time := rdtsc();
		
		result = #insert #run concat("inline ", function_name, "();");
		
		end_time := rdtsc();
		duration := cast(s64) (end_time - start_time);
		min_time = min(duration, min_time);
	}
	
	#if is_reference {
		`reference := cast(float) min_time;
	}
	
	println("%15: %, %.2 (%.2x)", function_name, result, min_time, `reference / min_time);
	
	return cast(float) min_time;
}

main :: () {
	for * data { << it = cast(u32) it_index; }
	
	benchmark("single", true);
	benchmark("dual");
	benchmark("quad");
	println("");
	benchmark("single_sse");
	benchmark("dual_sse");
	println("");
	benchmark("single_avx");
	benchmark("dual_avx");
}



#import "MyBasic";
#import "Machine_X64";