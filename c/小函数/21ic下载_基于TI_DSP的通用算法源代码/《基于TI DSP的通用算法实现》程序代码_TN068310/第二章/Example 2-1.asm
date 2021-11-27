;=========================================================================
;
; Example 2 - 1. Signed Fixed-Point Division ASM Subroutine for C5x/C54x
;
;=========================================================================


;=========================================================================
;	Temp1 --- numerator（被除数）,	Temp2 --- denominator（除数）
;	quot_i --- quotient（商）,	remain_i --- remainder（余数）
;=========================================================================



		LD    	temp1, T			；将分子（被除数）装入T寄存器
        MPY   	temp2, A			；分母（除数）与分子（被除数）相乘，结果放入
									; 累加器A
        LD		temp2, B			；将除数temp2装入B寄存器的低16位
        ABS		B					；求绝对值
		STL    	B, temp2			；将B寄存器的低16位存回temp2
		LD     	temp1, B			；将被除数temp1装入B寄存器的低16位
		ABS    	B					；求绝对值
		RPT    	#15					；重复SUBC指令16次
		SUBC   	temp2, B			；使用SUBC指令完成除法运算
		BCD    	div_end, AGT		；延时跳转，先执行下面两条指令，然后判断A，
									；若A0，则跳转到标号div_end，结束除法
		STL  	B, quot_i			；将商（B寄存器的低16位）存入变量quot_i
		STH  	B,remain_i		；将余数（B寄存器的高16位）
                                	；存入变量remain_i
		XOR 	B					；若两数相乘的结果为负，则商也应为负。
									；先将B寄存器清0
		SUB  	quot_i, B        	；将商反号
		STL  	B, quot_i			；存回变量quot_i中
 div_end
