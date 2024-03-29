/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010-2012 by Meika Sugimoto
 *  Copyright (C) 2015 by Naoki Saito
 *              Nagoya Municipal Industrial Research Institute, JAPAN
 * 
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
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
 *  @(#) $Id: logtask.c 1111 2008-06-12 08:42:26Z ertl-hiro $
 */

/*
 *		システムログタスク
 */

#include <kernel.h>
#include <t_syslog.h>
#include <log_output.h>
#include "syssvc/serial.h"
#include "syssvc/syslog.h"
#include "logtask.h"

/*
 *  システムログタスクの出力先のポートID
 */
static ID	logtask_portid;

/*
 *  シリアルインタフェースへの1文字出力
 */
static void
logtask_putc(char c)
{
	serial_wri_dat(logtask_portid, &c, 1);
}

/*
 *  ログタスクの初期化処理
 */

void logtask_initialize(ID log_portid)
{
	logtask_portid = log_portid;
	serial_opn_por(logtask_portid);
	syslog_msk_log(LOG_UPTO(LOG_INFO), LOG_UPTO(LOG_EMERG));
	syslog_1(LOG_NOTICE, "System logging task is started on port %d.",
													logtask_portid);
}
/*
 *  システムログタスクの本体
 */
void
logtask_main(intptr_t exinf)
{
	SYSLOG	syslog;
	static uint_t	lost = 0;
	ER_UINT	rercd;
	
	while ((rercd = syslog_rea_log(&syslog)) >= 0) {
		lost += (uint_t) rercd;
		if (syslog.logtype >= LOG_TYPE_COMMENT) {
			if (lost > 0U) {
				syslog_lostmsg(lost, logtask_putc);
				lost = 0U;
			}
			syslog_print(&syslog, logtask_putc);
			logtask_putc('\n');
		}
	}
	if (lost > 0U) {
		syslog_lostmsg(lost, logtask_putc);
	}
}

void cychdr_act_logtsk(intptr_t exinf)
{
	iact_tsk((ID)exinf);
}

/*
 *  システムログタスクの終了処理
 */
void
logtask_terminate(intptr_t exinf)
{
	char	c;
	SYSLOG	syslog;
	bool_t	msgflg = false;
	ER_UINT	rercd;

	/*
	 *  シリアルインタフェースドライバの送信バッファに蓄積されたデータ
	 *  を，低レベル出力機能を用いて出力する．
	 */
	while (serial_get_chr(logtask_portid, &c)) {
		target_fput_log(c);
	}

	/*
	 *  ログバッファに記録されたログ情報を，低レベル出力機能を用いて出
	 *  力する．
	 */
	while ((rercd = syslog_rea_log(&syslog)) >= 0) {
		if (!msgflg) {
			/*
			 *  ログバッファに残ったログ情報であることを示す文字列を出
			 *  力する．
			 */
			syslog_printf("-- buffered messages --\n", NULL, target_fput_log);
			msgflg = true;
		}
		if (rercd > 0) {
			syslog_lostmsg((uint_t) rercd, target_fput_log);
		}
		if (syslog.logtype >= LOG_TYPE_COMMENT) {
			syslog_print(&syslog, target_fput_log);
			target_fput_log('\n');
		}
	}
}
