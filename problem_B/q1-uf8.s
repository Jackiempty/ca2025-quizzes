.data
str_all_passed: .asciz "All tests passed.\n"
str_fail1: .asciz "%02x: produces value %d but encodes back to %02x\n"
str_fail2: .asciz "%02x: value %d <= previous_value %d\n"

.text
setup:
  li    ra, -1
  li    sp, 0x7ffffff0

main:
  #######################################################
  # < Function >
  #    main procedure
  #
  # < Parameters >
  #    NULL
  #
  # < Return Value >
  #    NULL
  #######################################################
  # < Local Variable >
  #    s0: string
  #######################################################

  ## Save ra & Callee Saved
  addi sp, sp, -12
  sw   ra, 8(sp)
  sw   s0, 4(sp)
  sw   s1, 0(sp)

  li   s0, 0x01000000

  ############### Call Function Procedure ###############
  # Caller Saved

  # Pass Arguments

  # Jump to Callee
  jal  ra, FUNC_TEST
  #######################################################
  ## Retrieve Caller Saved

  bne  a0, x0 ,main_pass
  li   s1, 88              # if not pass, load 88 to 0x01000000
  sw   s1, 0(s0)
  li   a0, 1               # return 1
  j    main_exit
main_pass:
  # la   s0, str_all_passed  # load string
  jal  ra, print_str       # go to print string
  li   s1, 66              # if pass, load 66 to 0x01000000
  sw   s1, 0(s0)
  li   a0, 0               # return 0
main_exit:
  ## Retrieve ra & Callee Saved
  lw   ra, 8(sp)
  lw   s0, 4(sp)
  sw   s1, 0(sp)
  addi sp, sp, 12

  ## return
  ret

print_str:
  # print_str: s0=address of string
  # For simulation, replace with ecall or system call as needed
  ret


FUNC_TEST:
  #######################################################
  # < Function >
  #    test
  #
  # < Parameters >
  #    NULL
  #
  # < Return Value >
  #    NULL
  #######################################################
  # < Local Variable >
  #    s0 : pass
  #    s1 : previous_value
  #    t0 : fl
  #    t1 : value
  #    t2 : fl2
  #    t3 : i
  #######################################################
  ## Save ra & Callee Saved
  addi sp, sp, -12
  sw   s0, 8(sp)
  sw   s1, 4(sp)
  sw   ra, 0(sp)

  li   s1, -1              # previous_value(s1) = -1
  li   s0, 1               # passed(s0) = true
  li   t3, 0               # i(t3) = 0

test_loop:
  li   t4, 256
  bge  t3, t4, test_end
  mv   t0, t3              # fl(t0) = i(t3)

  ############### Call Function Procedure ###############
  # Caller Saved
  addi sp, sp, -16
  sw   t0, 12(sp)
  sw   t1, 8(sp)
  sw   t2, 4(sp)
  sw   t3, 0(sp)

  # Pass Arguments
  mv   a0, t0

  # Jump to Callee
  jal  ra, uf8_decode

  ## Retrieve Caller Saved
  lw   t0, 12(sp)
  lw   t1, 8(sp)
  lw   t2, 4(sp)
  lw   t3, 0(sp)
  addi sp, sp, 16

  mv   t1, a0              # value(t1) = uf8_decode(fl)
  #######################################################

  ############### Call Function Procedure ###############
  # Caller Saved
  addi sp, sp, -16
  sw   t0, 12(sp)
  sw   t1, 8(sp)
  sw   t2, 4(sp)
  sw   t3, 0(sp)

  # Pass Arguments
  mv   a0, t1              # a0 = value(t1)

  # Jump to Callee
  jal  ra, uf8_encode

  ## Retrieve Caller Saved
  lw   t0, 12(sp)
  lw   t1, 8(sp)
  lw   t2, 4(sp)
  lw   t3, 0(sp)
  addi sp, sp, 16

  mv   t2, a0              # fl2(t2) = uf8_decode(value)
  #######################################################

  andi t0, t0, 0xff
  andi t2, t2, 0xff
  bne  t0, t2, test_fail1
endif1:
  bge  s1, t1, test_fail2
endif2:
  mv   s1, t1              # previous_value(s1) = value(t1)
  addi t3, t3, 1           # i(t3)++
  j    test_loop

test_fail1:
  li   s0, 0
  # print fail1: skip for now
  j    endif1

test_fail2:
  li   s0, 0
  # print fail2: skip for now
  j    endif2
test_end:
  mv   a0, s0              # return passed(s0)

  ## Retrieve ra & Callee Saved
  lw   s0, 8(sp)
  lw   s1, 4(sp)
  lw   ra, 0(sp)
  addi sp, sp, 12

  ## return
  ret

clz:
  #######################################################
  # < Function >
  #    clz
  #
  # < Parameters >
  #    a0 : x
  #
  # < Return Value >
  #    a0
  #######################################################
  # < Local Variable >
  #    t0 : n
  #    t1 : c
  #    t2 : y
  #######################################################
  ## Save ra & Callee Saved
  addi    sp, sp, -4
  sw      ra, 0(sp)

  ## function start
  li   t0, 32              # n = 32
  li   t1, 16              # c = 16
clz_loop:
  srl  t2, a0, t1          # y = x >> c
  beq  t2, x0, clz_skip
  sub  t0, t0, t1          # n -= c
  mv   a0, t2              # x = y
clz_skip:
  srli t1, t1, 1           # c >>= 1
  bne  t1, x0, clz_loop
  sub  a0, t0, a0          # return n - x

  ## Retrieve ra & Callee Saved
  lw   ra, 0(sp)
  addi sp, sp, 4

  ## return
  ret

uf8_decode:
  #######################################################
  # < Function >
  #    uf8_decode
  #
  # < Parameters >
  #    a0 : fl
  #
  # < Return Value >
  #    a0
  #######################################################
  # < Local Variable >
  #    t0 : mantissa
  #    t1 : exponent
  #    t2 : offset
  #######################################################
  ## Save ra & Callee Saved
  addi    sp, sp, -4
  sw      ra, 0(sp)

  ## funtion start
  andi t0, a0, 0x0f        # mantissa = fl & 0x0f
  srli t1, a0, 4           # exponent = fl >> 4
  li   t2, 0x7fff
  li   t3, 15
  sub  t3, t3, t1          # 15 - exponent
  srl  t2, t2, t3          # 0x7fff >> (15-exponent)
  slli t2, t2, 4           # << 4
  sll  t0, t0, t1          # mantissa << exponent
  add  a0, t0, t2          # (mantissa << exponent) + offset

  ## Retrieve ra & Callee Saved
  lw   ra, 0(sp)
  addi sp, sp, 4

  ## return
  ret

uf8_encode:
  #######################################################
  # < Function >
  #    uf8_encode
  #
  # < Parameters >
  #    a0 : value
  #
  # < Return Value >
  #    a0
  #######################################################
  # < Local Variable >
  #    t0 : lz
  #    t1 : msb
  #    t2 : exponent
  #    t3 : overflow
  #######################################################
  ## Save ra & Callee Saved
  addi    sp, sp, -4
  sw      ra, 0(sp)

  ## function start
  li   t0, 16
  bltu a0, t0, uf8_encode_ret # if value < 16, return value

  ############### Call Function Procedure ###############
  # Caller Saved
  addi    sp, sp, -16
  sw      t0, 12(sp)
  sw      t1, 8(sp)
  sw      t2, 4(sp)
  sw      t3, 0(sp)

  # Pass Arguments
  mv      a0, a0
  
  # Jump to Callee
  jal     ra, clz             # ra = Addr(ra = lw   t0, 20(sp) )
  
  ## Retrieve Caller Saved
  lw      t0, 12(sp)
  lw      t1, 8(sp)
  lw      t2, 4(sp)
  lw      t3, 0(sp)
  addi    sp, sp, 16

  mv      t0, a0              # lz = clz(value)
  #######################################################

  li   t1, 31                 # msb
  sub  t1, t1, t0             # msb(t1) = 31 - lz(t0)
  li   t2, 0                  # exponent(t2) = 0
  li   t3, 0                  # overflow(t3) = 0

  li   t4, 5
  bge  t1, t4, if1            # if(msb >=5)
  j    endif1                 # else
if1:
  addi t2, t1, -4             # exponent = msb - 4
  li   t4, 15
  blt  t4, t2, en_endif2         # if(exponent > 15)
  li   t2, 15                 # exponent = 15
en_endif2:
  li   t4, 0                  # e(t4) = 0
  # li   t6, 0
if1_for:
  bge  t4, t2, if1_for_end    # if e(t4) >= exponent(t2)
  slli t3, t3, 1
  addi t3, t3, 16
  addi t4, t4, 1              # e(t4)++
  j    if1_for
if1_for_end:

while1:
  beq  t2, x0, en_endif1         # exponent == 0
  bltu a0, t3, in_while1      # value < overflow
  j    en_endif1
in_while1:
  addi t3, t3, -16
  srli t3, t3, 1
  addi t2, t2, -1
  j    while1
en_endif1:

  li   t4, 15
in_while2:
  bge  t2, t4, end_while2    # exponent >= 15
  slli t5, t3, 1             # next_onerflow(t5)
  addi t5, t5, 16
  bltu a0, t5, end_while2    # if value < next_overflow
  mv   t3, t5                # overflow = next_overflow
  addi t2, t2, 1
  j    in_while2
end_while2:
  sub  t5, a0, t3            # mantissa(t5)
  srl  t5, t5, t2
  slli t2, t2, 4
  or   a0, t2, t5

uf8_encode_ret:
  ## Retrieve ra & Callee Saved
  lw   ra, 0(sp)
  addi sp, sp, 4

  ## return
  ret