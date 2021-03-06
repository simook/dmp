# Serenity is the background worker that checks and updates user characters with the latest from EVE.
class Serenity
  def perform
    User.all.each do |user|
      unless user.character.nil?
        # Get the latest from EVE if the cache time has expired.
        if user.character.cached_until <= DateTime.now
          EveCharacter::Sheet.update(user)
        end

        # Get the latest killlogs if the cache time has expired.
        if user.character.killlog_cached_until.nil? or user.character.killlog_cached_until <= DateTime.now
          EveCharacter::Killmails.create(user)
        end
      else

        # If a user doesn't have a charcter, lets create one (most likely a legacy user). Probably should make a special log of this.
        EveCharacter::Sheet.create(user)
      end

      unless user.corporation.nil?
        if user.corporation.cached_until <= DateTime.now
          EveCorporation::Sheet.update(user)
        end
        unless user.corp_apisecret.nil? and user.corp_apikey.nil?
          EveCorporation::Starbases.init(user)
          EveCorporation::StarbaseDetails.init(user)
        end
      else
        EveCorporation::Sheet.create(user)
      end
    end
  end

end

