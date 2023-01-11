problem1 :: () -> int {
	// If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
	// Find the sum of all the multiples of 3 or 5 below 1000.
	
	sum_of_multiples_below :: (factor: int, below_limit: int) -> int {
		
		// S   = 1*x + 2*x + 3*x + ... + n*x = 
		//       x*(1 +   2 +   3 + ... + n) =
		//       x*(n + n-1 + n-2 + ... + 1) =
		// 
		// 2*S = x * (n+1) * n
		// S = x * (n + 1) * n / 2
		
		n := (below_limit - 1) / factor; // -1 because we don't want to include the limit. The problem states *below* 1000.
		
		return factor * (n + 1) * n / 2;
	}
	
	limit := 1000;
	
	sum_of_multiples_of_3 := sum_of_multiples_below(3, limit);
	sum_of_multiples_of_5 := sum_of_multiples_below(5, limit);
	sum_of_multiples_of_3_and_5 := sum_of_multiples_below(15, limit); // Multiples of both 3 and 5 are multiples of 15.
	
	// n(A + B) = n(A) + n(B) + n(A intersection B)
	sum_of_multiples_of_3_or_5  := sum_of_multiples_of_3 + sum_of_multiples_of_5 - sum_of_multiples_of_3_and_5;
	
	return sum_of_multiples_of_3_or_5;
}

main :: () {
	check :: ($problem: int) {
		solutions :: int.[
			233168
		];
		
		given_solution   := #insert #run tprint("problem%();", problem);
		correct_solution := solutions[problem - 1];
		
		is_correct := given_solution == correct_solution;
		
		print("[%] problem %: % % %\n", ifx is_correct then "correct" else "incorrect", problem, given_solution, ifx is_correct then "==" else "!=", correct_solution);
	}
	
	check(1);
	
}
	
#import "Basic";
	