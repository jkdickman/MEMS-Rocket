import sensor, image, time

# Set the thresholds for the red color (may need adjustment)<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
red_threshold = (30, 100, 15, 127, 15, 127)  # LAB color space thresholds for red
distance_threshold = 150  # Distance threshold for resolution switch (in cm)
pixels_threshold = 200  # Minimum number of pixels in a blob
area_threshold = 200  # Minimum area (in pixels) of a blob
BALLOON_WIDTH = 30  # Known width of the balloon in cm
FOCAL_LENGTH = ... # Placeholder for focal length in pixel units

# Initialize the sensor
sensor.reset()
sensor.set_pixformat(sensor.RGB565)

# Start in high-resolution mode
sensor.set_framesize(sensor.FULL_RES)  # Replace with the actual constant for 2MP resolution
sensor.skip_frames(time = 2000)
clock = time.clock()

def estimate_distance(blob, known_width, focal_length):
    # Calculate the distance based on the perceived width of the blob
    # and the known width of the object (red balloon).
    # This method assumes the camera and object are aligned on the same plane.
    percieved_width = blob.w() # Width of the blob in pixels
    distance = (known_width * focal_length) / percieved_width
    return distance

while(True):
    clock.tick()
    img = sensor.snapshot()

    blobs = img.find_blobs([red_threshold], pixels_threshold=200, area_threshold=200, merge=True)

    if blobs:
        largest_blob = max(blobs, key=lambda b: b.pixels())
        img.draw_cross(largest_blob.cx(), largest_blob.cy())
        distance = estimate_distance(largest_blob, BALLOON_WIDTH, FOCAL_LENGTH)

        if high_res_mode and distance < distance_threshold:
            # Switch to low-resolution, high frame rate mode
            sensor.set_framesize(sensor.LOWER_RES)  # Replace with the actual constant for lower resolution
            high_res_mode = False

        print("Blob center:", largest_blob.cx(), largest_blob.cy(), "Distance:", distance)

    print("FPS:", clock.fps())
