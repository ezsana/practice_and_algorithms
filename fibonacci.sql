/*
 Function that returns the nth Fibonacci number
 Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, etc.
 */

CREATE OR REPLACE FUNCTION nth_fib(n int) RETURNS int AS $$
    DECLARE
        fib_number_1 int := 1;
        fib_number_2 int := 2;
        counter int := 3;
    BEGIN
         if n <= 1 then
             RETURN 0;
         end if;
         if n = 2 OR n = 3 then
             RETURN 1;
         end if;
         while counter < n loop
             counter := counter + 1;
             SELECT fib_number_2, fib_number_1+fib_number_2 INTO fib_number_1, fib_number_2;
         end loop;
         RETURN fib_number_1;
    END;
    $$
    LANGUAGE plpgsql;

SELECT nth_fib(3);