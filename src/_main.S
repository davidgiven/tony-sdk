#include "tony.inc"

entry:
	;lda shadow_01
	;ora #0x02
	;sta shadow_01
	;sta 0x01
        
        bra entry