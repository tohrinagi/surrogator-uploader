require 'net/ldap'
require 'pp'

#LDAP認証モジュール
module LdapAuth
  @@host
  @@port
  @@bae

  #ユーザークラス
  class LdapUser
    attr_reader :id, :mail, :group

    def initialize(id, mail, group)
      @id = id
      @mail = mail
      @group = group
    end
  end

  def self.initialize(host, port, base)
    @@host = host
    @@port = port
    @@base = base
  end

  def self.authenticate(id, password)
    return LdapUser.new(id,"id@example.com", "")
    ldap = Net::LDAP.new( :host => @@host, :port => @@port, :base => @@base,
      :auth => { :id => "#{id}", :password => password, :method => :simple } )

    group = Hash.new
    mail = ''
    if ldap.bind
      ldap.open do |item|
        filter = Net::LDAP::Filter.eq("cn", id)
        item.search(:filter => filter, :return_result => false ) do |entry|
          entry.each do |attr_name, values|
            group[attr_name] = values
          end
          #TODO get mail
        end
      end
    end
    return LdapUser.new(id, mail, group)
  rescue Net::LDAP::LdapError => e
    return nill
  end
end
