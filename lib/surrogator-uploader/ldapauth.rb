require 'net/ldap'

#LDAP認証モジュール
module LdapAuth
  @@host
  @@port
  @@bae

  #ユーザークラス
  class LdapUser
    attr_reader :id, :attribute

    def initialize(id, attribute)
      @id = id
      @attribute = attribute
    end
  end

  def self.initialize(host, port, base)
    @@host = host
    @@port = port
    @@base = base
  end

  def self.authenticate(id, password)
    ldap = Net::LDAP.new
    ldap.host = @@host
    ldap.port = @@port
    ldap.auth "uid=#{id},#{@@base}", password
    ldap.base = @@base

    attribute = Hash.new
    mail = ''
    if ldap.bind
      ldap.open do |item|
        filter = Net::LDAP::Filter.eq("cn", id)
        item.search(:filter => filter, :return_result => false ) do |entry|
          entry.each do |attr_name, values|
            attribute[attr_name] = values
          end
        end
      end
      return LdapUser.new(id, attribute)
    else
      return nil
    end
  rescue Net::LDAP::LdapError => e
    return nil
  end
end
