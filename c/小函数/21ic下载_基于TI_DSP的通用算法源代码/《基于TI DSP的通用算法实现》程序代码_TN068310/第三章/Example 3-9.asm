
;Example 3 - 9. Butterfly Unit ASM Listing for TMS320C54x

	STM		#fft_data, PX 		; PX ָ����ν������һ�����ݵ�ʵ����PR��
	LD		d_data_idx, A
	ADD		*(PX), A
	STLM 		A,  QX			; QX ָ����ν�����ڶ������ݵ�ʵ����QR��
	MVDK  		d_grps_cnt,  GROUP	; AR1�������������

GROUP:							; ������ÿһ����������
    	MVMD		butter_counter, BRC		; ��ÿһ���еĵ��ν�ĸ���װ��BRC
    	RPTBD		butterflyend - 1			
    	LD  		*WR, T				; WR����ת����ʵ����WIΪ�鲿
    	MPY  		*QX+, A				; A:=QR*WR || QX*QI
    	MAC  		*WI+0%, *QX-, A			; A:=QR*WR+QI*WI 
    	ADD  		*PX, 16, A, B			; B:=(QR*WR+QI*WI)+PR || QXָ��QR
	ST    		B, *PX				; PR':=((QR*WR+QI*WI)+PR)/2
||	SUB 		*PX+, B		            	; B:=PR-(QR*WR+QI*WI)
   	ST     		B, *QX				; QR':=(PR-(QR*WR+QI*WI))/2
|| 	MPY 		*QX+, A		           	 ; A:=QR*WI  [T=WI] || QXָ��QI
	MAS   		*QX, *WR+0%, A			; A:=QR*WI-QI*WR
	ADD   		*PX, 16, A, B			; B:=(QR*WI-QI*WR)+PI
	ST     		B, *QX+				; QI':=((QR*WI-QI*WR)+PI)/2
                                        		; || QXָ��QR
|| 	SUB  		*PX, B		              	; B:=PI-(QR*WI-QI*WR)
	LD   		*WR, T				; T:=WR
	ST    		B, *PX+		      		; PI':=(PI-(QR*WI-QI*WR))/2
                                        		; || PXָ��PR
|| 	MPY  		*QX+, A				; A:=QR*WR || QXָ��QI
butterflyend:
