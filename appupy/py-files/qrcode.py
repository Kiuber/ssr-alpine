import json
import base64
import os
import sys

# ssr://server:port:protocol:method:obfs:password_base64/?params_base64

class Config():
    def show_qrcode(self):
        config_path = '/etc/shadowsocksr.json'
        with open(config_path, 'r') as read_file:
            data = json.load(read_file)

            method = data['method']
            protocol = data['protocol']
            protocol_param = data['protocol_param']
            obfs = data['obfs']
            obfs_param = data['obfs_param']
            remarks = data['remarks']
            group = data['group']

            hostname = sys.argv[1]
            port = sys.argv[2]

            for docker_port, password in data['port_password'].items() :
# per params to base64
                obfs_param_base64 = self.encode64_by_urlsafe(obfs_param)
                protocol_param_base64 = self.encode64_by_urlsafe(protocol_param)
                remarks_base64 = self.encode64_by_urlsafe(remarks)
                group_base64 = self.encode64_by_urlsafe(group)

# build params then base64 encode
                params_plain = 'obfsparam={}&protoparam={}&remarks={}&group={}'.format(obfs_param_base64, protocol_param_base64, remarks_base64, group_base64)
                print('plain: %s' % params_plain)
                params_base64 = self.encode64_by_urlsafe(params_plain)
                password_base64 = self.encode64_by_urlsafe(password)

                plain = '{}:{}:{}:{}:{}:{}/?{}'.format(hostname, port, protocol, method, obfs, password_base64, params_base64)
                plain = 'ssr://{}'.format(self.encode64_by_urlsafe(plain))
                self.show_qrcode_in_terminal(plain)

    def show_qrcode_in_terminal(self, plain):
        print('plain: %s' % plain)
        cmd = 'qr ' + plain
        os.system(cmd)

    def encode64_by_urlsafe(self, string):
        return base64.urlsafe_b64encode((string).encode(encoding='utf-8')).replace('=', '')

if __name__ == '__main__':
    config = Config()
    config.show_qrcode()

