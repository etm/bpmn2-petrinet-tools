require_relative 'traces'

class Trans #{{{
  attr_reader :in, :ut
  def initialize(ein=[],eut=[])
    @in = ein
    @ut = eut
  end
  def add_i(ein)
    @in << ein; @in.uniq!
  end
  def add_o(eut)
    @ut << eut; @ut.uniq!
  end
  def add_io(ein,eut)
    add_i ein
    add_o eut
  end
  def find(ein)
    @ut if @in.include?(ein)
  end
end #}}}

def get_net(traces,places,transitions)
  traces.each do |tr|
    tr.each_index do |j|
      case tr[j].what
        when :start
          places << 'S'
        when :end
          places << 'E'
          if tr[j-1].what == :xor
            transitions['_E'] ||= Trans.new
            transitions['_E'].add_io(tr[j-1].label,tr[j].label)
          else
            transitions[tr[j-1].label] ||= Trans.new
            transitions[tr[j-1].label].add_o tr[j].label
          end
        when :trans
          if tr[j-1].what == :trans || tr[j-1].what == :par
            artificial = "_#{tr[j-1].label}_#{tr[j].label}"
            places << artificial
            transitions[tr[j].label] ||= Trans.new
            transitions[tr[j].label].add_i(artificial)
            transitions[tr[j-1].label].add_o(artificial)
          else
            transitions[tr[j].label] ||= Trans.new
            transitions[tr[j].label].add_i(tr[j-1].label)
          end
        when :xor
          places << tr[j].label
          if tr[j-1].what == :start
            transitions['_S'] ||= Trans.new
            transitions['_S'].add_io(tr[j-1].label,tr[j].label)
          elsif tr[j-1].what == :xor
            artificial = "_#{tr[j-1].label}_#{tr[j].label}"
            transitions[artificial] ||= Trans.new
            transitions[artificial].add_io(tr[j-1].label,tr[j].label)
          else
            transitions[tr[j-1].label] ||= Trans.new
            transitions[tr[j-1].label].add_o(tr[j].label)
          end
        when :par
          if tr[j-1].what == :trans
            artificial = "_#{tr[j-1].label}_#{tr[j].label}"
            places << artificial
            transitions[tr[j].label] ||= Trans.new
            transitions[tr[j].label].add_i(artificial)
            transitions[tr[j-1].label].add_o(artificial)
          else
            transitions[tr[j].label] ||= Trans.new
            transitions[tr[j].label].add_i(tr[j-1].label)
          end
      end
      places.uniq!
    end
  end
end
