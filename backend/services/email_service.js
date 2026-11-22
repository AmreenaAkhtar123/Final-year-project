
import nodemailer from 'nodemailer';

export const sendPasswordResetOtp = async (recipientEmail, otp) => {
  const emailUser = process.env.EMAIL_USER;
  const emailAppPassword = process.env.EMAIL_APP_PASSWORD;

  if (!emailUser || !emailAppPassword) {
    throw new Error('Email credentials are not configured.');
  }

  const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
      user: emailUser,
      pass: emailAppPassword,
    },
  });

  await transporter.sendMail({
    from: `"MindMate" <${emailUser}>`,
    to: recipientEmail,
    subject: 'Your MindMate Password Reset OTP',
    text: `Your MindMate password reset code is ${otp}. This code expires in 5 minutes. If you did not request this code, please ignore this email.`,
    html: `
      <div style="font-family: Arial, sans-serif; background-color: #FCFCFC; padding: 30px;">
        <div style="max-width: 480px; margin: auto; background: white; padding: 30px; border-radius: 16px;">
          <h2 style="color: #1D2B3A;">MindMate Password Reset</h2>

          <p style="color: #555; font-size: 15px;">
            We received a request to reset your MindMate password.
          </p>

          <div style="background: #EFF7F3; padding: 20px; text-align: center; border-radius: 12px; margin: 25px 0;">
            <h1 style="color: #1D2B3A; letter-spacing: 8px; margin: 0;">
              ${otp}
            </h1>
          </div>

          <p style="color: #555; font-size: 14px;">
            This verification code expires in <strong>5 minutes</strong>.
          </p>

          <p style="color: #888; font-size: 13px;">
            If you did not request a password reset, you can safely ignore this email.
          </p>

          <p style="color: #65B594; font-weight: bold;">
            The MindMate Team
          </p>
        </div>
      </div>
    `,
  });
};
