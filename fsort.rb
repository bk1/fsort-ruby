class Numeric
  def metric
    to_i
  end
end

class Fixnum
  def metric
    self
  end
end

class Float
  def metric
    to_i
  end
end

class String
  def metric
    r = 0
    8.times do |i|
      x = getbyte(i) || -1
      x += 1
      r *= 257
      r += x
    end
    r
  end
end


class Array
  private
  def calculate_k(factor, value, lsize)
    # calculate prod as factor*value, add a small delta for rounding, force it into the closed interval [0,lsize-1] using min and max
    prod_unlimited = factor * value + 1e-9
    prod_non_negative = [0, prod_unlimited].max
    prod_float = [prod_non_negative, lsize-1].min
    prod_float.to_i
  end

  public
  def fsort()
    fsort_f(0.42)
  end

  def fsort_f(factor)
    nsize = size()
    # size <= 1: nothing needs to be sorted
    return self if (nsize <= 1)

    # use calculate_k for a purpose it has not been made for, but since it is identical with what is needed here it is correct
    # we want lsize to be <= nsize and >= 2
    lsize_small = calculate_k(nsize, factor, nsize);
    lsize = [2, lsize_small].max
    l = [0] * lsize
    # find minimum of self
    amin = min()
    # find maximum of self
    amax = max()

    # we sort based on <=> and not based on ==.
    # so it is safer to check if amin and amax are the same in terms of <=>.  Then it is already sorted
    return self if (amin <=> amax) == 0

    amin_metric = amin.metric
    amax_metric = amax.metric
    step = (lsize - 1).to_f/(amax_metric - amin_metric)
    # iterate through self
    each do |x|
      x_metric = x.metric
      k = calculate_k(step, x_metric - amin_metric, lsize)
      l[k]+= 1
      #puts "x=#{x} x.metric=#{x_metric} step=#{step} k=#{k} l[k]=#{l[k]}"
    end

    #puts "l=#{l.inspect}"
    ll = l.inject([0]) do |partial_list, entry|
      last_of_partial = partial_list.last
      partial_list << last_of_partial + entry
    end
    #puts "ll=#{l.inspect}"

    result = [nil] * nsize
    
    positions = ll.clone

    each do |x|
      k = calculate_k(step, x.metric() - amin_metric, lsize)
      pos = positions[k]
      result[pos] = x
      positions[k] += 1
    end
    #puts "positions=#{positions.inspect}"
    #puts("grouped: #{result.inspect}")

    ll.shift
    ll.inject(0) do |prev, current|
      result[prev..current] = result[prev..current].sort
      current
    end

    result
  end

end

