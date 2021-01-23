class Cricketer < ApplicationRecord
  # Select players from the country 'Australia'
  scope :australian_players, -> { where(country: "Australia")}

  # Select players with the role 'Batter'
  scope :batters, -> { where(role: 'Batter') }

  # Select players with the role 'Bowler'
  scope :bowlers, -> { where(role: 'Bowler') }

  # Sort players by the descending number of matches played
  scope :descending_by_matches, -> { order(matches: :desc) }

  # Batting average: Runs scored / (Number of innings in which player has been out)
  #
  # Note:
  # - If any of runs scored, innings batted and not outs are missing,
  #   return nil as the data is incomplete.
  # - If the player has not batted yet, return nil
  # - If the player has been not out in all innings, return runs scored.
  def batting_average
    if (self.runs_scored == nil || 
        self.innings_batted == nil || 
        self.innings_batted == 0 || 
        self.not_out == nil)
      return nil
    elsif(self.innings_batted == self.not_out)
      return self.runs_scored
    else 
      return self.runs_scored.to_f / (self.innings_batted - self.not_out) 
    end
  end

  # Batting strike rate: (Runs Scored x 100) / (Balls Faced)
  #
  # Note:
  # - If any of runs scored and balls faced are missing, return nil as the
  #   data is incomplete
  # - If the player has not batted yet, return nil
  def batting_strike_rate
    if (self.runs_scored == nil || self.balls_faced == nil || self.balls_faced == 0)
      return nil
    else 
      return self.runs_scored.to_f * 100 / self.balls_faced 
    end
  end

  # Create records for the classical batters
  def self.import_classical_batters
    classical_batters=[
    ['Sachin Tendulkar', 'India', 'Batter', 200, 329, 33, 15921, nil, 248, 51, 68],
    ['Rahul Dravid', 'India', 'Batter', 164, 286, 32, 13288, 31258, 270, 36, 63],
    ['Kumar Sangakkara', 'Sri Lanka', 'Wicketkeeper', 134, 233, 17, 12400, 22882, 319, 38, 52],
    ['Ricky Ponting', 'Australia', 'Batter', 168, 287, 29, 13378, 22782, 257, 41, 62],
    [ 'Brian Lara', 'West Indies', 'Batter', 131, 232, 6, 11953, 19753, 400, 34, 48]] 
    fields = ['name', 'role', 'matches', 'innings_batted','not_out', 'runs_scored', 'balls_faced',
      'high_score', 'centuries','half_centuries']

    classical_batters.each do |batter|
      record = Cricketer.new
      fields.each_with_index do |field, i|
        record[field] = batter[i]
      end
      record.save
    end
  end

  # Update the current data with an innings scorecard.
  #
  # A batting_scorecard is defined an array of the following type:
  # [Player name, Is out, Runs scored, Balls faced, 4s, 6s]
  #
  # For example:
  # [
  #   ['Rohit Sharma', true, 26, 77, 3, 1],
  #   ['Shubham Gill', true, 50, 101, 8, 0],
  #   ...
  #   ['Jasprit Bumrah', false, 0, 2, 0, 0],
  #   ['Mohammed Siraj', true, 6, 10, 1, 0]
  # ]
  #
  # There are atleast two batters and upto eleven batters in an innings.
  #
  # A bowling_scorecard is defined as an array of the following type:
  # [Player name, Balls bowled, Maidens bowled, Runs given, Wickets]
  #
  # For example:
  # [
  #   ['Mitchell Starc', 114, 7, 61, 1],
  #   ['Josh Hazzlewood', 126, 10, 43, 2],
  #   ...
  #   ['Cameron Green', 30, 2, 11, 0]
  # ]
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception with the player's name as
  # the message.
  def self.update_innings(batting_scorecard, bowling_scorecard)
    batting_scorecard.each do |batter|
      record = Cricketer.find_by(name: batter[0])
      raise ActiveRecord::RecordNotFound.new(batter[0]) if record == nil

      was_out = batter[1]
      runs = batter[2]    #runs scored this inning
      balls = batter[3]   #balls faced this inning
      no4 = batter[4]     #no of 4s
      no6 = batter[5]     #no of 6s

      record.matches += 1
      record.innings_batted += 1
      record.not_out += 1 unless was_out
      record.runs_scored += runs
      record.balls_faced += balls
      record.fours_scored += no4
      record.sixes_scored += no6

      record.high_score = runs if runs > record.high_score

      if runs >= 100 
        record.centuries += runs/100
      elsif runs >= 50
        record.half_centuries += 1
      end
      record.save
    end

    bowling_scorecard.each do |bowler|
      record = Cricketer.find_by(name: bowler[0])
      raise ActiveRecord::RecordNotFound.new(bowler[0]) if record == nil

      balls = bowler[1]   #balls bowled
      runs = bowler[3]    #runs given
      wickets = bowler[4] #wickets taken

      record.matches += 1
      record.innings_bowled += 1
      record.balls_bowled += balls
      record.runs_given += runs
      record.wickets_taken += wickets

      record.save
    end
  end

  # Delete the record associated with a player.
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception.
  def self.ban(name)
    record = Cricketer.find_by(name: name)
    raise ActiveRecord::RecordNotFound.new("No player by name #{name}") if record == nil
    record.delete
  end
end
