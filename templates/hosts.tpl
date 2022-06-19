[rhel_ml_hosts]
%{ for ip in rhel_ml_hosts ~}
${ip}
%{ endfor ~}