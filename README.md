## FitCity

FitCity is a fitness platform that allows users to discover gyms and trainers in their city, book personal training sessions, and purchase monthly gym memberships. Members can chat with trainers, receive real-time notifications, and pay for services using cash or card. Gym administrators manage members, trainers, payments, and control gym access via QR code check-ins, while system administrators oversee all data and manage gyms displayed on the city map. The application provides an end-to-end solution for gym discovery, booking, payments, and access management.
## Docker Build

To build the backend using Docker, first navigate to the `backend` folder and unzip the `.env` file using the password `fit`. After extracting the environment file, go to the `infra/docker` directory and run `docker compose build` to build the Docker containers.

## Builds

Desktop applications (Gym Admin and Central Admin) are located in the `builds/desktop` folder, while mobile application builds (Trainer and Member) can be found in the `builds/mobile` directory.

## Demo Login Credentials for admins

| Role / Gym            | Email                         | Password            |
|-----------------------|-------------------------------|---------------------|
| Central Admin         | central@fitcity.local         | central             |
| Gym Admin (Baščaršija)| admin.bascarsija@fitcity.local| gymadmin3           |
| Gym Admin (Grbavica)  | admin.grbavica@fitcity.local  | gymadmin4           |
| Gym Admin (Downtown)  | admin.downtown@fitcity.local  | gymadmin1           |
| Gym Admin (Ilidža)    | admin.ilidza@fitcity.local    | gymadmin2           |
| Gym Admin (Grada)     | admin.grada@fitcity.local     | gymgrada1           |
| Gym Admin (Bosna)     | admin.bosna@fitcity.local     | gymbosna1           |

## Demo Member Accounts

| Role   | Email                         | Password |
|--------|-------------------------------|----------|
| Member | member01@seed.fitcity.local   | seedpass |
| Member | member11@seed.fitcity.local   | seedpass |
| Member | member16@seed.fitcity.local   | seedpass |
| Member | member24@seed.fitcity.local   | seedpass |

## Demo Trainer Accounts

| Role    | Email               | Password     |
|---------|---------------------|--------------|
| Trainer | trainer1@gym.local  | trainer1pass |
| Trainer | trainer2@gym.local  | trainer2pass |
| Trainer | trainer3@gym.local  | trainer3pass |

## Notes

For using the QR code scanner via camera, the desktop application must be in focus at the time of scanning (i.e. it must be the last clicked/active window). QR scanning will not work if the desktop app is running in the background. For Stripe payments, it is required to generate a valid webhook signing secret using the Stripe CLI command `stripe listen --forward-to https://localhost:5001/api/stripe/webhook`, then copy the generated `whsec_...` value and replace the existing Stripe webhook secret in the `.env` file located in the `backend` directory before testing payments. If thats problem I implemented "hardcoded" version of paying which will just change paying status to paid.

## App Behavior

The desktop application is intended only for administrative roles (Central Admin and Gym Admins) and is not accessible to regular members/trainers. A user can apply for a gym membership in the mobile app - ; if the request is approved, the user is immediately prompted to pay for the membership inside the app, and if it is rejected the gym admin can provide a rejection reason (e.g., the gym is at capacity). When a member books a session with a trainer, the chat with that trainer includes the option to pay (if card payment was selected) for card you can use 4242 4242 4242 4242, and once the session is confirmed/booked the trainer receives a chat message indicating that the session has been booked. 

## RabbitMQ

RabbitMQ is used for logging incoming messages into the `NotificationLogs` table and for running a background worker that consumes these messages and sends email notifications.



