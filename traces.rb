require 'xml/smart'

$xorc = 0
$parc = 0
Item = Struct.new(:what,:id,:label,:type)

def get_traces(what,traces=[])
  traces << [] unless traces.last
  ct = traces.last
  oc = what.find('b:outgoing').length > 1 ? :open : :close
  case what.qname.name
    when 'startEvent'
      ct.push Item.new(:start, 'start', 'S')
    when 'endEvent'
      ct.push Item.new(:end, 'end', 'E')
    when 'task', 'serviceTask', 'userTask'
      ct.push Item.new(:trans, what.attributes['id'], what.attributes['name'].strip.gsub(/\n/,''))
    when 'exclusiveGateway'
      what.attributes['mid'] = 'x' + ($xorc+=1).to_s unless what.attributes['mid']
      ct.push Item.new(:xor, what.attributes['id'], what.attributes['mid'], oc)
    when 'parallelGateway'
      what.attributes['mid'] = 'p' + ($parc+=1).to_s unless what.attributes['mid']
      ct.push Item.new(:par, what.attributes['id'], what.attributes['mid'], oc)
  end
  return if traces.last.find_all{ |i| i.id == what.attributes['id'] }.length == 2
  count = 0
  ot = ct.dup
  what.find('b:outgoing').each do |e|
    traces << ot.dup if count > 0
    get_traces e.find("//*[b:incoming=\"#{e.text()}\"]").first, traces
    count += 1
  end
end
