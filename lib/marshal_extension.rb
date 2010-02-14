# Shamelessly swiped from: http://pastie.org/720905
# Initial implementation from: http://kballcodes.com/2009/09/05/rails-memcached-a-better-solution-to-the-undefined-classmodule-problem/
class << Marshal
  def load_with_rails_classloader(*args)
    begin
      load_without_rails_classloader(*args)
    rescue ArgumentError, NameError => e
      if e.message =~ %r(undefined class/module)
        const = e.message.split(' ').last
        const.constantize
        retry
      else
        raise(e)
      end
    end
  end

  alias_method_chain :load, :rails_classloader
end
