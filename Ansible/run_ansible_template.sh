ansible-playbook   \
  --private-key <PEM File Location>   \
  --inventory   hosts.cfg   \
  -e  'ansible_python_interpreter=/usr/bin/python3'      \
  playbook.yml