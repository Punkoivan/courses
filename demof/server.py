import cherrypy
import subprocess
import os

revoke_cert_command = r'echo this is %node_name%'
# server lamp1 10.0.0.1:80 check
# server template
serv_template = 'server %node_name% %ip%:%port% check'


class Balancer_Server(object):
    @cherrypy.expose
    def add(self, node_name, ip_addres, port):
        new_server = serv_template.replace('%node_name%', node_name).replace('%ip%', ip_addres).replace('%port%', port)
        haproxy_file = open('hproxy_config.cfg')
        haproxy_data = haproxy_file.read()
        haproxy_file.close()

        haproxy_data = haproxy_data.replace('#nodes_lamp', '#nodes_lamp\n    ' + new_server)
        haproxy_file = open('hproxy_config.cfg', 'w')
        haproxy_file.write(haproxy_data)
        haproxy_file.close()
        return "ok"

    @cherrypy.expose
    def remove(self, node_name, ip_addres, port):
        haproxy_file = open('hproxy_config.cfg')
        haproxy_data = haproxy_file.read()
        haproxy_file.close()

        haproxy_data = haproxy_data.replace(
            serv_template.replace('%node_name%', node_name).replace('%ip%', ip_addres).replace('%port%', port), '')
        print(serv_template.replace('%node_name%', node_name).replace('%ip%', ip_addres).replace('%port%', port))
        haproxy_file = open('hproxy_config.cfg', 'w')
        haproxy_file.write(haproxy_data)
        haproxy_file.close()

        # revoke keys
        run_command = revoke_cert_command.replace('%node_name%', node_name)
        os.system(run_command)

        return "ok"

if __name__ == '__main__':
    cherrypy.config.update({'server.socket_host': '0.0.0.0',
                        'server.socket_port': 9999,
                       })
    cherrypy.quickstart(Balancer_Server())