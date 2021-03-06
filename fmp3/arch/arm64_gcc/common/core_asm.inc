/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2011-2020 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *
 *  上記著作権者は，以下の(1)～(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *  @(#) $Id: core_asm.inc 225 2020-02-25 05:47:06Z ertl-honda $
 */

/*
 *		アセンブリ言語用マクロ定義（ARM64 GNU開発環境用）
 */

#ifndef TOPPERS_CORE_ASM_INC
#define TOPPERS_CORE_ASM_INC

/*
 *  ディレクティブのマクロ定義
 */
#define ASECTION(name)	.section name, "a"
#define ATEXT			.text
#define AGLOBAL(name)	.global name
#define AALIGN(size)	.align size
#define ABALIGN(size)	.balign size
#define ALONG			.dword /* 8byte値を配置したいなら.dwordを使用する */
#define ALABEL(label)	label:
#define AOR				|
#define AAND			&
#define ALSR			>>
#define ANOT(x)			(~x)
#define AWEAK(name)		.weak name

/*
 *  セクション情報
 */
#define DATA_START		__start_data
#define DATA_END		__end_data
#define IDATA_START		__start_idata
#define BSS_START		__start_bss
#define BSS_END			__end_bss

#if defined(TOPPERS_CORTEX_A53) || defined(TOPPERS_CORTEX_A57)

.macro my_core_index re_reg sc_reg1
	mrs		\re_reg, mpidr_el1
	and		\re_reg, \re_reg, #MPIDR_AFF0_MASK
.endm

#ifdef USE_THREAD_ID_PCB
.macro my_pcb re_reg sc_reg1
	mrs		\re_reg, tpidr_el1
.endm
#else /* USE_THREAD_ID_PCB */
.macro my_pcb re_reg sc_reg1
	mrs		\re_reg, mpidr_el1
	and		\sc_reg1, \re_reg, #MPIDR_AFF0_MASK
	and		\re_reg, \re_reg, #MPIDR_AFF1_MASK
	eor		\re_reg, \re_reg, #(1 << MPIDR_AFF_SHIFT)  // swap A53/A57 order
	add		\sc_reg1, \sc_reg1, \re_reg, lsr #6
	ldr		\re_reg, =p_pcb_table
	ldr		\re_reg, [\re_reg, \sc_reg1, lsl #3]
.endm
#endif /* USE_THREAD_ID_PCB */

.macro my_istkpt re_reg sc_reg1
	mrs		\sc_reg1, mpidr_el1
	and		\sc_reg1, \sc_reg1, #MPIDR_AFF0_MASK
	ldr		\re_reg, =_kernel_istkpt_table
	ldr		\re_reg, [\re_reg, \sc_reg1, lsl #3]
.endm

#endif /* defined(TOPPERS_CORTEX_A53) || defined(TOPPERS_CORTEX_A57) */

#endif /* TOPPERS_CORE_ASM_INC */
