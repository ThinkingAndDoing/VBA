#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import poplib
from email.mime.text import MIMEText
from email.header import Header

class getemail:
	def __init__(self):
		self.host = "pop3.163.com"
		self.username = "15192535292@163.com"
		self.password = "###"
		self.pp = poplib.POP3(self.host)	# 创建一个pop3对象，这个时候实际上已经连接上服务器了

	def login(self):
		#self.pp.set_debuglevel(1)	# 设置调试模式，可以看到与服务器的交互信息
		self.pp.user(self.username)	# 向服务器发送用户名
		self.pp.pass_(self.password)	# 向服务器发送密码

	def getmailboxinfo(self):
		ret = self.pp.stat()	# 获取服务器上信件信息，返回是一个列表，第一项是一共有多少封邮件，第二项是共有多少字节
		print(ret)
		# 需要取出所有信件的头部，信件id是从1开始的。
		for i in range(1, ret[0]+1):
			# 取出信件头部。注意：top指定的行数是以信件头为基数的，也就是说当取0行，
			# 其实是返回头部信息，取1行其实是返回头部信息之外再多1行。
			mlist = self.pp.top(i, 0)
			print('line: ', len(mlist[1]))
		ret = self.pp.list()	# 列出服务器上邮件信息，这个会对每一封邮件都输出id和大小。不象stat输出的是总的统计信息

	def getemails(self):
		down = self.pp.retr(1)	# 取第一封邮件完整信息，在返回值里，是按行存储在down[1]的列表里的。down[0]是返回的状态信息
		# 输出邮件
		for line in down[1]:
			print(line.decode("utf-8"))

	def quit(self):
		self.pp.quit()

def testGetEmail():
	pop = getemail()
	pop.login()
	pop.getemails()
	#pop.getmailboxinfo()
	pop.quit()

testGetEmail()
