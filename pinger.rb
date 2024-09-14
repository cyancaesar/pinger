require 'net/ping'
require 'colorize'

def banner
    title = "Pinger @ cyancaesar\nICMP ping sweep host discovery".light_yellow
    print <<-END
#{title}
Usage:
    ./pinger <IP>
Examples:
    Ping a host
        ./pinger 192.168.1.30
    Ping the whole network
        ./pinger 192.168.1.1/24
    Ping a range of hosts
        ./pinger 192.168.1.20-30
    END
end

def main
    return banner if ARGV.size.eql? 0
    arg = ARGV.first.strip
    host = []
    case arg
    when /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/24)$/
        networkPortion = arg.slice(0,(arg.rindex "."))
        1.upto(254) {|x| host.push(networkPortion + "." + x.to_s)}
        pingNetwork(host)

    when /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\-\d{1,3})$/
        networkPortion = arg.slice(0,(arg.rindex "."))
        initialLength = arg.size - networkPortion.size - (arg.size - arg.rindex("-")+1)
        i = arg.slice((arg.rindex ".")+1, initialLength)
        f = arg.slice((arg.rindex "-")+1, 3)
        i.upto(f) {|x| host.push(networkPortion + "." + x.to_s)}
        pingRange(host)

    when /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/
        host.push(arg)
        pingSingle(host)

    else
        return banner
    end
end

def ping(host)
    for ip in host
        req = Net::Ping::ICMP.new(ip, nil, 0.15.to_f)
        if req.ping?
            puts "#{ip} is UP".light_green
        # else
        #     puts "#{ip} is DOWN".light_red
        end
    end
end

def pingNetwork(host)
    puts "Sending ICMP requests to the whole network".yellow
    ping(host)
end

def pingRange(host)
    puts "Ping from #{host.first} to #{host.last}".yellow
    ping(host)
end

def pingSingle(host)
    puts "Ping #{host.first}".yellow
    ping(host)
end

begin
    main
rescue => exception
    puts exception.to_s
end
