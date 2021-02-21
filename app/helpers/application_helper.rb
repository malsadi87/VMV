module ApplicationHelper
    $token   = nil
  $beta    = nil
  $loglink = nil
  $name    = nil
  $contract= nil
  $hvote   = nil
  $pkey    = nil
  $code    = nil


  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z') + Array('0'..'9')
    $token = Array.new(number) { charset.sample }.join
  end


  def code(value)
    $code = value
  end

  def token
    $token
  end

  def beta(value)
    $beta = value
  end

  def loglink(value)
    $loglink = value
  end

  def name(value)
    $name = value
  end

  def hvote(value)
    $hvote = value
  end

  def bkey(value)
    $pkey = value
  end

  def getVote
    return $hvote
  end

  def getKey
    return $pkey
  end

  def getBeta
    return $beta
  end

  def getCode
    return $code
  end

  def getLink
    return $loglink
  end

  def getName
    return $name
  end

  def flash_class(level)
    case level
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end

  def contract(contract)
    puts "adding contract"
    $contract = contract
    puts $contract
  end

  def getContract
    return $contract
  end
end
