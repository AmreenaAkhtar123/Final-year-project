import express from 'express';
import User from '../models/User.js';
import CheckIn from '../models/CheckIn.js';

const router = express.Router();

router.get('/api/progress', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Make sure the user exists.
    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    // Get all check-ins for this user.
    const checkIns = await CheckIn.find({
      email: normalizedEmail,
    })
      .sort({
        createdAt: 1,
      })
      .lean();

    // --------------------------------
    // BASIC COUNTS
    // --------------------------------

    const totalCheckIns = checkIns.length;

    const reflectionsWritten = checkIns.filter(
      (checkIn) =>
        typeof checkIn.reflection === 'string' &&
        checkIn.reflection.trim().length > 0
    ).length;

    const emotionsIdentified = checkIns.filter(
      (checkIn) =>
        Array.isArray(checkIn.emotions) &&
        checkIn.emotions.length > 0
    ).length;

    const factorsIdentified = checkIns.filter(
      (checkIn) =>
        Array.isArray(checkIn.factors) &&
        checkIn.factors.length > 0
    ).length;

    // --------------------------------
    // REFLECTION RATE
    // --------------------------------

    const reflectionRate =
      totalCheckIns === 0
        ? 0
        : reflectionsWritten / totalCheckIns;

    // --------------------------------
    // SELF-AWARENESS SCORE
    // --------------------------------
    //
    // This is an engagement metric, not
    // a clinical or psychological score.
    //

    const emotionRate =
      totalCheckIns === 0
        ? 0
        : emotionsIdentified / totalCheckIns;

    const factorRate =
      totalCheckIns === 0
        ? 0
        : factorsIdentified / totalCheckIns;

    const selfAwarenessRate =
      totalCheckIns === 0
        ? 0
        : Math.min(
            1,
            reflectionRate * 0.4 +
              emotionRate * 0.35 +
              factorRate * 0.25
          );

    // --------------------------------
    // CURRENT STREAK
    // --------------------------------

    const uniqueDates = [
      ...new Set(
        checkIns.map((checkIn) =>
          new Date(checkIn.createdAt)
            .toISOString()
            .split('T')[0]
        )
      ),
    ].sort();

    const dateSet = new Set(uniqueDates);

    let currentStreak = 0;

    if (uniqueDates.length > 0) {
      let cursor = new Date(
        `${uniqueDates[uniqueDates.length - 1]}T00:00:00`
      );

      while (true) {
        const dateKey = cursor
          .toISOString()
          .split('T')[0];

        if (!dateSet.has(dateKey)) {
          break;
        }

        currentStreak++;

        cursor.setDate(cursor.getDate() - 1);
      }
    }

    // --------------------------------
    // LONGEST STREAK
    // --------------------------------

    let longestStreak = 0;
    let runningStreak = 0;
    let previousDate = null;

    for (const dateString of uniqueDates) {
      const currentDate = new Date(
        `${dateString}T00:00:00`
      );

      if (previousDate === null) {
        runningStreak = 1;
      } else {
        const difference =
          (currentDate - previousDate) /
          (1000 * 60 * 60 * 24);

        if (difference === 1) {
          runningStreak++;
        } else {
          runningStreak = 1;
        }
      }

      longestStreak = Math.max(
        longestStreak,
        runningStreak
      );

      previousDate = currentDate;
    }

    // --------------------------------
    // WEEKLY CHECK-INS
    // --------------------------------

    const weeklyCheckIns = [0, 0, 0, 0, 0];

    if (checkIns.length > 0) {
      const latestDate = new Date(
        checkIns[checkIns.length - 1].createdAt
      );

      for (const checkIn of checkIns) {
        const checkInDate = new Date(
          checkIn.createdAt
        );

        const difference =
          Math.floor(
            (latestDate - checkInDate) /
              (1000 * 60 * 60 * 24)
          );

        const weekIndex =
          4 - Math.floor(difference / 7);

        if (
          weekIndex >= 0 &&
          weekIndex < 5
        ) {
          weeklyCheckIns[weekIndex]++;
        }
      }
    }

    // --------------------------------
    // MOST ACTIVE WEEK
    // --------------------------------

    const mostActiveWeek =
      weeklyCheckIns.length === 0
        ? 0
        : Math.max(...weeklyCheckIns);

    // --------------------------------
    // MOST REFLECTIVE WEEK
    // --------------------------------

    const weeklyReflections = [0, 0, 0, 0, 0];

    if (checkIns.length > 0) {
      const latestDate = new Date(
        checkIns[checkIns.length - 1].createdAt
      );

      for (const checkIn of checkIns) {
        if (
          typeof checkIn.reflection !== 'string' ||
          !checkIn.reflection.trim()
        ) {
          continue;
        }

        const checkInDate = new Date(
          checkIn.createdAt
        );

        const difference =
          Math.floor(
            (latestDate - checkInDate) /
              (1000 * 60 * 60 * 24)
          );

        const weekIndex =
          4 - Math.floor(difference / 7);

        if (
          weekIndex >= 0 &&
          weekIndex < 5
        ) {
          weeklyReflections[weekIndex]++;
        }
      }
    }

    const mostReflectiveWeek =
      weeklyReflections.length === 0
        ? 0
        : Math.max(...weeklyReflections);

    // --------------------------------
    // MOST ACTIVE MONTH
    // --------------------------------

    const monthCounts = {};

    for (const checkIn of checkIns) {
      const date = new Date(checkIn.createdAt);

      const monthName = date.toLocaleString(
        'en-US',
        {
          month: 'long',
        }
      );

      monthCounts[monthName] =
        (monthCounts[monthName] || 0) + 1;
    }

    let mostActiveMonth = null;
    let highestMonthCount = 0;

    for (const [month, count] of Object.entries(
      monthCounts
    )) {
      if (count > highestMonthCount) {
        highestMonthCount = count;
        mostActiveMonth = month;
      }
    }

    // --------------------------------
    // JOURNEY SCORE
    // --------------------------------
    //
    // Engagement-based score:
    // - consistency
    // - reflection
    // - self-awareness
    // - streak
    //
    // Not a mental-health score.
    //

    const consistencyScore = Math.min(
      1,
      totalCheckIns / 30
    );

    const streakScore = Math.min(
      1,
      longestStreak / 30
    );

    const journeyScore = Math.round(
      (
        consistencyScore * 0.35 +
        reflectionRate * 0.20 +
        selfAwarenessRate * 0.25 +
        streakScore * 0.20
      ) * 100
    );

    // --------------------------------
    // AI INSIGHTS
    // --------------------------------
    //
    // AI analysis is currently shown after
    // check-ins, but the CheckIn document
    // does not store the AI analysis.
    //
    // Therefore we don't invent a number.
    //

    const aiInsightsReceived = 0;

    // --------------------------------
    // MILESTONES
    // --------------------------------

    const milestones = {
      firstCheckIn: totalCheckIns >= 1,
      sevenDayStreak: longestStreak >= 7,
      tenReflections: reflectionsWritten >= 10,
      firstAssessment: false,
      thirtyCheckIns: totalCheckIns >= 30,
      thirtyDayConsistency: longestStreak >= 30,
    };

    // --------------------------------
    // NEXT MILESTONE
    // --------------------------------

    let nextMilestone = 'firstCheckIn';
    let nextMilestoneTarget = 1;
    let nextMilestoneCurrent = totalCheckIns;

    if (totalCheckIns < 1) {
      nextMilestone = 'firstCheckIn';
      nextMilestoneTarget = 1;
      nextMilestoneCurrent = totalCheckIns;
    } else if (totalCheckIns < 30) {
      nextMilestone = 'thirtyCheckIns';
      nextMilestoneTarget = 30;
      nextMilestoneCurrent = totalCheckIns;
    } else if (longestStreak < 30) {
      nextMilestone = 'thirtyDayConsistency';
      nextMilestoneTarget = 30;
      nextMilestoneCurrent = longestStreak;
    } else {
      nextMilestone = 'journeyMastery';
      nextMilestoneTarget = 100;
      nextMilestoneCurrent = journeyScore;
    }

    const nextMilestoneProgress =
      Math.min(
        1,
        nextMilestoneCurrent /
          nextMilestoneTarget
      );

    // --------------------------------
    // JOURNEY START
    // --------------------------------

    const journeyStartedAt =
      checkIns.length > 0
        ? checkIns[0].createdAt
        : null;

    // --------------------------------
    // RESPONSE
    // --------------------------------

    return res.status(200).json({
      message: 'Progress retrieved successfully.',

      progress: {
        journeyScore,

        totalCheckIns,
        currentStreak,
        longestStreak,

        reflectionsWritten,
        emotionsIdentified,
        factorsIdentified,

        reflectionRate,
        selfAwarenessRate,

        weeklyCheckIns,

        mostActiveWeek,
        mostReflectiveWeek,

        mostActiveMonth,

        aiInsightsReceived,

        milestones,

        nextMilestone,
        nextMilestoneTarget,
        nextMilestoneCurrent,
        nextMilestoneProgress,

        journeyStartedAt,
      },
    });
  } catch (error) {
    console.error(
      'Get progress error:',
      error
    );

    return res.status(500).json({
      message: 'Failed to retrieve progress data.',
    });
  }
});

export default router;
