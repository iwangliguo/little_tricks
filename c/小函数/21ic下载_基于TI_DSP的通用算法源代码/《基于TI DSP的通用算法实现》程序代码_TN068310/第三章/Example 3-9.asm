
;Example 3 - 9. Butterfly Unit ASM Listing for TMS320C54x

	STM		#fft_data, PX 		; PX 指向蝶形结运算第一个数据的实部（PR）
	LD		d_data_idx, A
	ADD		*(PX), A
	STLM 		A,  QX			; QX 指向蝶形结运算第二个数据的实部（QR）
	MVDK  		d_grps_cnt,  GROUP	; AR1是组个数计数器

GROUP:							; 以下是每一组的运算过程
    	MVMD		butter_counter, BRC		; 将每一组中的蝶形结的个数装入BRC
    	RPTBD		butterflyend - 1			
    	LD  		*WR, T				; WR是旋转因子实部，WI为虚部
    	MPY  		*QX+, A				; A:=QR*WR || QX*QI
    	MAC  		*WI+0%, *QX-, A			; A:=QR*WR+QI*WI 
    	ADD  		*PX, 16, A, B			; B:=(QR*WR+QI*WI)+PR || QX指向QR
	ST    		B, *PX				; PR':=((QR*WR+QI*WI)+PR)/2
||	SUB 		*PX+, B		            	; B:=PR-(QR*WR+QI*WI)
   	ST     		B, *QX				; QR':=(PR-(QR*WR+QI*WI))/2
|| 	MPY 		*QX+, A		           	 ; A:=QR*WI  [T=WI] || QX指向QI
	MAS   		*QX, *WR+0%, A			; A:=QR*WI-QI*WR
	ADD   		*PX, 16, A, B			; B:=(QR*WI-QI*WR)+PI
	ST     		B, *QX+				; QI':=((QR*WI-QI*WR)+PI)/2
                                        		; || QX指向QR
|| 	SUB  		*PX, B		              	; B:=PI-(QR*WI-QI*WR)
	LD   		*WR, T				; T:=WR
	ST    		B, *PX+		      		; PI':=(PI-(QR*WI-QI*WR))/2
                                        		; || PX指向PR
|| 	MPY  		*QX+, A				; A:=QR*WR || QX指向QI
butterflyend:
