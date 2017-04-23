#	Marta Pacuszka - zadanie 6 projekt 1
#	Zmniejszanie obrazka

		.globl main
		.data
temp:		.space 4 #bufor wczytywania
size:		.space 4 #rozmiar wczytywanego pliku *.bmp
width:		.space 4 #szerokość wczytywanego pliku
height:		.space 4 #wysokość wczytywanego pliku
new_size:	.space 4 #rozmiar pliku wyjściowego
new_width:	.space 4 #szerokość pliku wyjściowego
new_height:	.space 4 #wysokość pliku wyjściowego
off:		.space 4 #offset wczytywanego pliku (poczatek tablicy pikseli)
new_off:	.space 4 #offset pliku wyjściowego
padd:		.space 1 #ilosc bitow paddingowych wczytywaneog pliku
new_padd:	.space 1 #ilosc bitow paddingowych pliku wyjsciowego
msg:		.asciiz "Marta Pacuszka - zmniejszanie obrazka\n"
input:		.asciiz	"/home/marta/arko/projekt/motyl.bmp"
output:		.asciiz "/home/marta/arko/projekt/out3.bmp"
err1:		.asciiz "Blad odczytu pliku zrodlowego\n"
err2:		.asciiz "Blad tworzenia pliku docelowego\n"
		.text
main:	la $a0, msg	# wczytanie adresu stringa msg do rejestru a0
	li $v0, 4	# ustawienie syscall na wypisywanie stringa
	syscall		# wypisanie na ekranie zawartosci stringa msg

wczytaj_plik_in:
# $t0 - deskryptor
# $t1 - adres zalokowanej pamięci
# $t4 - rozmiar
	la $a0, input	# wczytanie nazwy pliku do otwarcia
	li $a1, 0	# flags, 0 for read-only, ignoruje mode
	li $a2, 0	# mode
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# $v0 zawiera deskryptor
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 2	# maximum number of characters to read
	li $v0, 14	# odczyt z pliku
	syscall		# $v0 contains number of characters read
	
	# odczytanie rozmiaru
	move $a0, $t0	
	la $a1, size	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	lw $t4, size	# przekopiowanie rozmiaru pliku do rejestru t4
	
	# alokacja pamięci o rozmiarze pliku (adres w $t1)
	move $a0, $t4	
	li $v0, 9	# ustawienie syscall na alokacje pamieci
	syscall		# zaalokowanie pamieci o rozmiarze pliku
	
	move $t1, $v0	# przekopiowanie adesu zaalokowanej pamieci do rejestru t1
	
	# odczytanie 4 bajtów zarezerwowanych
	move $a0, $t0	
	la $a1, temp	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie offsetu
	move $a0, $t0	
	la $a1, off	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie wielkości nagłówka informacyjnego
	move $a0, $t0	
	la $a1, temp	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie szerokosci
	move $a0, $t0	
	la $a1, width
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie wysokości
	move $a0, $t0	
	la $a1, height	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# zamkniecie pliku
	move $a0, $t0	
	li $v0, 16	
	syscall		

odczytaj_plik_in:
	# wczytuje tablice pikseli do pod adres zaalokowanej pamieci w $t1:
	# ponowne otwarcie pliku
	la $a0, input	
	li $a1, 0	
	li $a2, 0	
	li $v0, 13	
	syscall		
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	
	la $a1, ($t1)	# wskazanie wczesniej zaalokowanej pamieci jako miejsca do wczytania
	la $a2, ($t4)	# ustawienie odczytu tylu bajtow ile ma plik
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall
	
	# zamkniecie pliku
	move $a0, $t0	
	li $v0, 16	
	syscall		
	
wczytaj_plik_out:
# $t0 - deskryptor
# $t3 - adres zalokowanej pamięci
# $t4 - rozmiar
	# otwarcie pliku
	la $a0, output	
	li $a1, 0	
	li $a2, 0	
	li $v0, 13	
	syscall		
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	# odczyt 2 bajtow 'BM'
	move $a0, $t0	
	la $a1, temp	
	li $a2, 2	
	li $v0, 14	
	syscall		
	
	# odczytanie rozmiaru (4 bajty)
	move $a0, $t0	
	la $a1, new_size	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	lw $t4, new_size	# przekopiowanie rozmiaru pliku do rejestru t4
	
	# alokacja pamięci o rozmiarze pliku (adres w $t3)
	move $a0, $t4	
	li $v0, 9	# ustawienie syscall na alokacje pamieci
	syscall		# zaalokowanie pamieci o rozmiarze pliku
	
	move $t3, $v0	# przekopiowanie adesu zaalokowanej pamieci do rejestru t3
	
	# odczytanie 4 bajtów zarezerwowanych
	move $a0, $t0	
	la $a1, temp	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie offsetu
	move $a0, $t0	
	la $a1, new_off	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie wielkości nagłówka informacyjnego
	move $a0, $t0	
	la $a1, temp	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie szerokosci
	move $a0, $t0	
	la $a1, new_width
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# odczytanie wysokości
	move $a0, $t0	
	la $a1, new_height	
	li $a2, 4	
	li $v0, 14	
	syscall		
	
	# zamkniecie pliku
	move $a0, $t0	
	li $v0, 16	
	syscall

odczytaj_plik_out:
	# wczytuje tablice pikseli do pod adres zaalokowanej pamieci w $t3:
	# ponowne otwarcie pliku
	la $a0, output	
	li $a1, 0	
	li $a2, 0	
	li $v0, 13	
	syscall		
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	
	la $a1, ($t3)	# wskazanie wczesniej zaalokowanej pamieci jako miejsca do wczytania
	la $a2, ($t4)	# ustawienie odczytu tylu bajtow ile ma plik
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall
	
	# zamkniecie pliku
	move $a0, $t0	
	li $v0, 16	
	syscall	
	
alokacja_miejsca_na_etap_przejsciowy:
	# etap przejsciowy - zmniejszanie tylko szerokości obrazka
	# zaalokowanie pamięci - adres w $t2
	# szerokość - new_width
	# wysokość - height
	lw $s0, new_width 	#do $s0 wczytuję nowa szerokosc
	lw $s1, height		#do $s1 wczytuje stara wysokosc
	li $t5, 4		#do $t5 wpisuje const=4

	#sprawdzam ilosc bitow paddingowych dla nowej szerokosci
	mul $t6, $s0, 3		#3 bajty na kazdy piksel
	div $t6, $t5 		#dziele szerokosc przez 4
	mfhi $t0 		#pobieram resztę z dzielenia szerokości przez 4
	
	beqz $t0, padding0

padding123:
	
	subu $t0, $t5, $t0      # padding = 4 - reszta z dzelenia
	sb $t0, new_padd
	
	add $t6, $t6, $t0 	# nowa prawdidlowa szerokowsc = nowa szerkokość + padding
	mul $t6, $t6, $s1	# rozmiar etapu przejsciowego
	
	#alokacja pamięci
	la $a0,($t6)
	li $v0, 9		# ustawienie syscall na alokacje pamieci
	syscall			# zaalokowanie pamieci o rozmiarze pliku
	move $t2, $v0		# przekopiowanie adesu zaalokowanej pamieci do rejestru t2
	
	j padding_pliku_in

padding0:

	li $t0, 0     		# padding = 0
	sb $t0, new_padd
	
	mul $t6, $t6, $s1
	
	#alokacja pamięci
	la $a0,($t6)
	li $v0, 9		# ustawienie syscall na alokacje pamieci
	syscall			# zaalokowanie pamieci o rozmiarze pliku
	move $t2, $v0		# przekopiowanie adesu zaalokowanej pamieci do rejestru t2
	

padding_pliku_in:

	lw $s2, width 		# do $s2 wczytuję szerokosć pliku wejsciowego
	mul $t6, $s2, 3
	div $t6, $t5 		# chcę tę szerkosć usupełnić do liczby podzielnej przez 4
	
	mfhi $t6 		# pobieram resztę z dzielenia szerokości przez 4
	beqz $t6, padding0_in
	
	subu $a3, $t5 ,$t6      # padding = 4 - reszta z dzelenia
	sb $a3, padd	
	j etap_przejsciowy
	
padding0_in:
	
	li $a3, 0     		# padding = 0
	sb $a3, padd	
	
etap_przejsciowy:
	# $t0 - liczba bitow paddingowych pliku wyjściowego
	# $a3 - liczba bitow paddingowych pliku wejściowego
	
	# $t6 - offset
	# $t8 - wskaznik bufora wejsciowego
	# $t9 - wskaznik bufora przejsciowego
	
	# do wyliczania jaka czesc starego piksela znajduje sie w nowym
	# $t4 - licznik wejsiowy (=new_width)
	# $t5 - licznik wyjsciowy (=width)
	
	# liczniki:
	# $s3 - ile pikseli zostalo do przerobienia (wys x szer)
	# $s4 - licznik szerokosci (starej)
	# $s5 - licznik szerokosci (nowej)
	
	# srednia kolorow
	# a0 B
	# a1 G
	# a2 R
	
	# dane piksela wczytanego z pliku wejsciowego
	# s0 B
	# s1 G
	# s2 R
	
	# ustawienie wskaźnika bufora wejściowego na pierwszy bajt pierwszego piksela do wczytania
	lw $t6, off
	add $t8, $t1, $t6	#przesuniecie o offset
	
	# ustawienie wskaźnika bufora przejsciowego na pierwszy bajt pierwszego piksela do wczytania
	add $t9, $t2, $zero	#wskaźnik na bufor przejsciowy
	
	# licznik wejsciowy i wyjsciowy sluza do liczenia jaka czesc starego piksela znajduje sie w nowym
	# i czy nalezy juz zaladowac kolejny piksel
	lw $t4, new_width 	# licznik wejsciowy
	lw $t5, width 		# liczniik wyjsciowy

	# do $s3 zapiszę ilość pikseli wejściowych do przerobienia
	lw $s3, height 		
	mul $s3, $t5, $s3	# width*height #########################czy tu jest ok?
	addi $s3, $s3, -1 
	
	# licznik szerokosci wejsciowej
	add $s4, $t5, -1	#jesli licznik = 0 to przejdz do nast linijki
	
	# licznik szerokosci przejsciowej
	add $s5, $t4, -1	#jesli licznik = 0 to przejdz do nast linijki
	
	li $a0, 0 		#srednia blue = 0
	li $a1, 0 		#srednia dla green = 0
	li $a2, 0 		#srednia dla red = 0
	
wczytaj_pixel:
	lbu $s0, ($t8)		# wczytaj b piksela do s0
	addiu $t8, $t8, 1
	lbu $s1, ($t8)		# wczytaj g piksela do s1
	addiu $t8, $t8, 1
	lbu $s2, ($t8)		# wczytaj r piksela do s2
	
oblicz_nowy_piksel:
	
	# porownuję licznik wejściowy i wyjściowy
	# mogą zaistnieć 3 przypadki:
	# przypadek1: $t4 <= $ t5 -> 	nowy piksel nie jest w całosci obliczony, nalezy przestawic wskaznik $t8 na 
	#				kolejny piksel pliku wejściowego
	# przypadek2: $t4 > $t5 ->	nowy piksel w całosci obliczony, ale stary nachodził na niego tylko częściowo,
	#				należy zapisać obliczony nowy piksel i wskaźnik %t9 przestawić na zapis kolejnego
	# przypadek3: $t4 = $t5	->	oba piksele obsłużone całkowicie, obydwa wskaźniki należy przestawić dalej
	beq $t4, $t5, przypadek3 # licznik we = licznik wy
	ble $t4, $t5, przypadek1 # licznik we <= licznik wy
	bgt $t4, $t5, przypadek2 # licznik we > licznik wy
	
przypadek3:
	
	mul $t7, $s0, $t4 	#b * licznik we 
	add $a0, $a0, $t7
	mul $t7, $s1, $t4 	#g * licznik we 
	add $a1, $a1, $t7
	mul $t7, $s2, $t4 	#r * licznik we 
	add $a2, $a2, $t7
	
	beqz $s3, etap_koncowy #ilość pikseli do przerobienia = 0 -> przechodzimy do skalowania po wysokości
	
	jal przesun_wsk_we_szerokosc
	jal przesun_wsk_wy_szerokosc
	j wczytaj_pixel
	
przypadek1:
	sub $t5, $t5, $t4 	#licznik wy = licznik wy - licznik we
	
	mul $t7, $s0, $t4 	#b * licznik we 
	add $a0, $a0, $t7
	mul $t7, $s1, $t4 	#g * licznik we 
	add $a1, $a1, $t7
	mul $t7, $s2, $t4 	#r * licznik we 
	add $a2, $a2, $t7
	
	beqz $s3, etap_koncowy #ilość pikseli do przerobienia = 0 -> przechodzimy do skalowania po wysokości
	jal przesun_wsk_we_szerokosc
	j wczytaj_pixel
	
przypadek2:

	sub $t4, $t4, $t5 	#licznik_we  = licznik_we  - licznik_wy
	
	mul $t7, $s0, $t5 	#b * licznik_wy 
	add $a0, $a0, $t7
	mul $t7, $s1, $t5 	#g * licznik_wy 
	add $a1, $a1, $t7
	mul $t7, $s2, $t5 	#r * licznik_wy 
	add $a2, $a2, $t7
	
	beqz $s3, etap_koncowy 	#ilość pikseli do przerobienia = 0 to zapisz plik
	
	jal przesun_wsk_wy_szerokosc
	j oblicz_nowy_piksel
		

przesun_wsk_we_szerokosc:

	beqz $s4, omin_padding_we #jesli licznik = 0 to przejdz do nast linijki
	j CDprzesun_wsk_we_szerokosc

omin_padding_we:
	add $t8, $t8, $a3
	lw $s4, width		#licznik szerokosci
	
CDprzesun_wsk_we_szerokosc:
	add $s4, $s4, -1	
	#przed przesunieciem wskaźnik wskazywał na ostatni bajt piksela
	#aby wskazywał na pierwszy bajt nowego piksela nalezy przesunac go o 1
	addi $t8, $t8, 1 
	lw $t4, new_width 	#licznik_we = new_width
	jr $ra

przesun_wsk_wy_szerokosc:
	#załadowanie nowo policzonego koloru pixela
	lw $t6, width
	
	div $a0, $a0, $t6
	sb $a0, ($t9)
	addi $t9, $t9, 1
	
	div $a1, $a1, $t6
	sb $a1, ($t9)
	addi $t9, $t9, 1
	
	div $a2, $a2, $t6
	sb $a2, ($t9)
	
	beqz $s5, omin_padding_wy
	j CDprzesun_wsk_wy_szerokosc

omin_padding_wy:
	add $t9, $t9, $t0
	lw $s5, new_width	#licznik szerokosci
	
CDprzesun_wsk_wy_szerokosc:
	add $s5, $s5, -1	#jesli licznik = 0 to przejdz do nast linijki
	addi $t9, $t9, 1
	
	# zerowanie srednich dla kolorow
	li $a0, 0
	li $a1, 0
	li $a2, 0
	
	addi $s3, $s3, -1 	#ilość pikseli do przerobienia
	lw $t5, width 		#licznik wy = szerokosc wejsciowego
	jr $ra
	
etap_koncowy:
	# wskazniki na pierwszy wiersz - zmiana gdy następuje zmiana kolumny
	# $t0 - wskaznik bufora przejsciowego w pierwszym wierszu
	# $a3 - wskaznik bufora wyjsciowego w pierwszym wierszu
	
	# $t6 - offset
	# $t8 - wskaznik bufora przejsciowego
	# $t9 - wskaznik bufora wyjsciowego
	
	# do wyliczania jaka czesc starego piksela znajduje sie w nowym
	# $t4 - licznik wejsiowy (=new_height)
	# $t5 - licznik wyjsciowy (=height)
	
	# liczniki:
	# $s3 - ile pikseli zostalo do przerobienia (wys x szer)
	# $s4 - licznik wysokości (starej)
	# $s5 - licznik wysokości (nowej)
	
	# $k0 - pozostala szerokosc we
	# $k1 - pozostala szerokosc wy
	
	# srednia kolorow
	# a0 B
	# a1 G
	# a2 R
	
	# dane piksela wczytanego z pliku wejsciowego
	# s0 B
	# s1 G
	# s2 R
	
	# ustawienie wskaźnika buforow przejsciowych na pierwszy bajt pierwszego piksela do wczytania
	add $t8, $t2, $zero	#wskaźnik na bufor przejsciowy
	add $t0, $t2, $zero
	# ustawienie wskaźnika buforow wyjściowych na pierwszy bajt pierwszego piksela do wczytania
	lw $t6, new_off
	add $t9, $t3, $t6	#przesuniecie o offset
	add $a3, $t3, $t6
	
	# licznik wejsciowy i wyjsciowy sluza do liczenia jaka czesc starego piksela znajduje sie w nowym
	# i czy nalezy juz zaladowac kolejny piksel
	lw $t4, new_height 	# licznik wejsciowy
	lw $t5, height 		# liczniik wyjsciowy

	lw $k0, new_width		# liczniki ile szerokosci jeszcze zostalo - aby wiedziec o ile sie przesuwac
	add $k1, $k0, $zero		# $k0 dla przejsciowego, $k1 dla wyjsciowego
	
	
	# do $s3 zapiszę ilość pikseli przejsciowych do przerobienia		
	mul $s3, $t5, $k0	# new_width*height
	addi $s3, $s3, -1 
	
	# licznik wysokosci przejsciowej
	add $s4, $t5, -1	#jesli licznik = 0 to przejdz do nast linijki
	
	# licznik wysokosci wyjsciowej
	add $s5, $t4, -1	#jesli licznik = 0 to przejdz do nast linijki
	
	# do rejestru $t6 wklejam zawartosc $k0 zeby potem niepotrzebnie nie ladowac z pamieci raz jeszcze
	add $t6, $k0, $zero	# $t6 bedzie sluzylo do wyliczenia szerokosci linijki
	
	# liczniki szerokosci
	add $k0, $k0, -1 	# od licznikow szerokosci odejmuje 1 bo sa sprawdzane czy = 0 przed zmniejszeniem
	add $k1, $k1, -1
	
	li $a0, 0 		#srednia blue = 0
	li $a1, 0 		#srednia dla green = 0
	li $a2, 0 		#srednia dla red = 0
	
	# licze dlugosc linijki w pliku wyjsciowym ($t6)
	# w $t6 jest juz zaladowane new_width
	mulu $t6, $t6, 3
	lb $t7, new_padd
	add $t6, $t6, $t7	# przesuniecie=pozostala szerokosc * 3  + new_padd
	add $t6, $t6, -2	# bo przesuwam sie z 3go bajtu ostatniego piksela na 1szy bajt pierwszego w linijce

	
wczytaj_pixel_2:
	lbu $s0, ($t8)		# wczytaj b piksela do s0
	addiu $t8, $t8, 1
	lbu $s1, ($t8)		# wczytaj g piksela do s1
	addiu $t8, $t8, 1
	lbu $s2, ($t8)		# wczytaj r piksela do s2
	
oblicz_nowy_piksel_2:
	
	# porownuję licznik wejściowy i wyjściowy
	# mogą zaistnieć 3 przypadki:
	# przypadek1: $t4 <= $ t5 -> 	nowy piksel nie jest w całosci obliczony, nalezy przestawic wskaznik $t8 na 
	#				kolejny piksel pliku wejściowego
	# przypadek2: $t4 > $t5 ->	nowy piksel w całosci obliczony, ale stary nachodził na niego tylko częściowo,
	#				należy zapisać obliczony nowy piksel i wskaźnik %t9 przestawić na zapis kolejnego
	# przypadek3: $t4 = $t5	->	oba piksele obsłużone całkowicie, obydwa wskaźniki należy przestawić dalej
	beq $t4, $t5, przypadek3_2 # licznik we = licznik wy
	ble $t4, $t5, przypadek1_2 # licznik we <= licznik wy
	bgt $t4, $t5, przypadek2_2 # licznik we > licznik wy
	
przypadek3_2:
	
	mul $t7, $s0, $t4 	#b * licznik we 
	add $a0, $a0, $t7
	mul $t7, $s1, $t4 	#g * licznik we 
	add $a1, $a1, $t7
	mul $t7, $s2, $t4 	#r * licznik we 
	add $a2, $a2, $t7
	
	beqz $s3, zapisz_plik #ilość pikseli do przerobienia = 0 -> koniec!
	
	jal przesun_wsk_we_2
	jal przesun_wsk_wy_2
	j wczytaj_pixel_2
	
przypadek1_2:
	sub $t5, $t5, $t4 	#licznik wy = licznik wy - licznik we
	
	mul $t7, $s0, $t4 	#b * licznik we 
	add $a0, $a0, $t7
	mul $t7, $s1, $t4 	#g * licznik we 
	add $a1, $a1, $t7
	mul $t7, $s2, $t4 	#r * licznik we 
	add $a2, $a2, $t7
	
	beqz $s3, zapisz_plik #ilość pikseli do przerobienia = 0 -> zero!
	
	jal przesun_wsk_we_2
	j wczytaj_pixel_2
	
przypadek2_2:

	sub $t4, $t4, $t5 	#licznik_we  = licznik_we  - licznik_wy
	
	mul $t7, $s0, $t5 	#b * licznik_wy 
	add $a0, $a0, $t7
	mul $t7, $s1, $t5 	#g * licznik_wy 
	add $a1, $a1, $t7
	mul $t7, $s2, $t5 	#r * licznik_wy 
	add $a2, $a2, $t7
	
	beqz $s3, zapisz_plik 	#ilość pikseli do przerobienia = 0 to zapisz plik
	
	jal przesun_wsk_wy_2
	j oblicz_nowy_piksel_2
		

przesun_wsk_we_2:

	beqz $s4, nast_kolumna_we #jesli licznik = 0 to przejdz do nast kolumny
	j CDprzesun_wsk_we_2

nast_kolumna_we:
	add $t8, $t0, 3 # wskaznik na nastepna kolumne
	add $t0, $t0, 3
	lw $s4, height		#licznik wysokosci
	add $s4, $s4, -1
	
	lw $t4, new_height 	# licznik_we = new_height
	add $k0, $k0, -1
	
	jr $ra
	
CDprzesun_wsk_we_2:
	add $s4, $s4, -1	
	add $t8, $t8, $t6	# przesuniecie wskaznika o szerokosc linii 
	lw $t4, new_height 	# licznik we = new_height
	jr $ra

przesun_wsk_wy_2:
	#załadowanie nowo policzonego koloru pixela
	lw $s6, height
	
	div $a0, $a0, $s6
	sb $a0, ($t9)
	addi $t9, $t9, 1
	
	div $a1, $a1, $s6
	sb $a1, ($t9)
	addi $t9, $t9, 1
	
	div $a2, $a2, $s6
	sb $a2, ($t9)
	
	beqz $s5, nast_kolumna_wy
	j CDprzesun_wsk_wy_2

nast_kolumna_wy:
	add $t9, $a3, 3  # przesuniecie wskaznika na kolejna kolumne
	add $a3, $a3, 3
	lw $s5, new_height	#licznik wysokosci
	add $s5, $s5, -1
	
	add $k1, $k1, -1	# pozostala szerokosc
	
	# zerowanie srednich dla kolorow
	li $a0, 0
	li $a1, 0
	li $a2, 0
	
	addi $s3, $s3, -1 	#ilość pikseli do przerobienia
	lw $t5, height 		#licznik wy = wysokosc wejsciowego
	jr $ra
	
CDprzesun_wsk_wy_2:
	
	add $t9, $t9, $t6
	#lw $s5, new_height	#licznik wysokosci
	add $s5, $s5, -1
	
	#add $k1, $k1, -1	# pozostala szerokosc
	
	# zerowanie srednich dla kolorow
	li $a0, 0
	li $a1, 0
	li $a2, 0
	
	addi $s3, $s3, -1 	#ilość pikseli do przerobienia
	lw $t5, height 		#licznik wy = szerokosc wejsciowego
	jr $ra
	
zapisz_plik:
	
	la $a0, output	# wczytanie nazwy pliku do otwarcia
	li $a1, 1	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik_out	# przeskocz do blad_plik_out jesli wczytywanie sie nie powiodlo
	
	#zapis pikseli
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, ($t3)	# wskazanie wczesniej zaalokowanej pamieci jako danych do zapisania
	lw $a2, new_size	# ustawienie zapisu tylu bajtow ile ma plik
	li $v0, 15	# ustawienie syscall na zapis do pliku
	syscall		
	
	#zamknij plik
	move $a0, $t0	# przekopiowanie deskryptora pliku do a0
	li $v0, 16	# ustawienie syscall na zakmniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0
	
koniec:	
	li $v0, 10	# ustawienie syscall na terminate
	syscall		# wyjscie z programu


blad_plik:
	la $a0, err1
	li $v0, 4
	syscall
	j koniec	

blad_plik_out:
	la $a0, err2
	li $v0, 4
	syscall
	j koniec
	

