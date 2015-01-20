import mraa, socket, string, time, sys

if len(sys.argv) < 5:
    print 'Usage: python phsringnotify <ircserver> <botnick> <channel> <targetnik>'
    print "   ex: python phsringnotify 10.254.166.45 '[PHSdeto]' '#projA' deton"
    quit()

ircserver = sys.argv[1]
botnick = sys.argv[2]
channel = sys.argv[3]
targetnick = sys.argv[4]

#some user data, change as per your taste
PORT = 6667
PRIVMSG = 'PRIVMSG ' + channel + ' :@' + targetnick + ' RING'

THRESHOLD = 100
DEADTIME = 20
prevOn = 0

#open a socket to handle the connection
# http://www.codereading.com/codereading/python/python-irc-client.html
IRC = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
IRC.settimeout(0.6)

#open a connection with the server
def irc_conn():
    IRC.connect((ircserver, PORT))

#simple function to send data through the socket
def send_data(command):
    IRC.send(command + '\n')

#join the channel
def join(channel):
    send_data("JOIN %s" % channel)

#send login data (customizable)
def login(nickname, username='user', password = None, realname='phsringnotify.py', hostname='localhost', servername='Server'):
    send_data("USER %s %s %s %s" % (username, hostname, servername, realname))
    send_data("NICK " + nickname)

irc_conn()
login(botnick)
join(channel)

aio = mraa.Aio(0)

while (1):
    time.sleep(0.3)

    v = aio.read()
    print '%d' % v,
    sys.stdout.flush()
    if v > THRESHOLD:
        now = time.time()
        if now - prevOn >= DEADTIME:
            print 'PRIVMSG'
            send_data(PRIVMSG + ' (%d)' % v)
            prevOn = now

    try:
        buffer = IRC.recv(1024)
        msg = string.split(buffer)
        if msg[0] == "PING": #check if server have sent ping command
            send_data("PONG %s" % msg[1]) #answer with pong as per RFC 1459
    except socket.timeout: #ignore
        continue
