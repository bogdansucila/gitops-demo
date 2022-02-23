import socket
from OpenSSL import SSL
import certifi
import sys, json

hostname = f'oidc.eks.{sys.argv[1]}.amazonaws.com'
port = 443


context = SSL.Context(method=SSL.TLSv1_METHOD)
context.load_verify_locations(cafile=certifi.where())

conn = SSL.Connection(context, socket=socket.socket(socket.AF_INET, socket.SOCK_STREAM))
conn.settimeout(5)
conn.connect((hostname, port))
conn.setblocking(1)
conn.do_handshake()
conn.set_tlsext_host_name(hostname.encode())

thumbprint = conn.get_peer_cert_chain()[-1].digest("sha1")
obj = {"thumbprint": thumbprint.decode("utf-8").replace(":", "").lower() }
print(json.dumps(obj))
conn.close()