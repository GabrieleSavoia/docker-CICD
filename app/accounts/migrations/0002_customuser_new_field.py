# Generated by Django 4.0 on 2023-07-04 12:33

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='customuser',
            name='new_field',
            field=models.PositiveIntegerField(default=11),
            preserve_default=False,
        ),
    ]
