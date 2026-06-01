# Architecture

# Views

These are created for end users to consume. The design was based on the following business questions:

**1. Team season summary**
For any team in any competition, I want to see their full season record in one row: games played, wins, draws, losses, goals scored, goals conceded, goal difference, total points, points per game, clean sheet count. I also want home and away breakdowns of the same — not separate tables, same row.

**2. Match results with full context**
For any match, I want one row that tells me everything without joining anything myself: the competition name, matchday, date, home team name, away team name, full time score, half time score, and the result (Home Win / Away Win / Draw). I don't want IDs — I want names.

**3. Rolling team form**
For any team, I want to see their last 5 matches in sequence: the date, the opponent name, home or away, the score, and points earned that match. I want to be able to filter by team. I'll use this to assess current form.

**4. Head to head record**
For any two teams, I want their all-time record against each other in this dataset: total meetings, team A wins, team B wins, draws, total goals scored by each side. One summary row per pairing.

**5. League table as of any matchday**
For a given competition and matchday, I want the league table at that point in the season — ranked by points, then goal difference, then goals scored. Columns: position, team name, played, won, drawn, lost, goals for, goals against, goal difference, points.
